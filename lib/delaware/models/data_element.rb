# frozen_string_literal: true

module Delaware
  module Models
    # Represents a data element.
    class DataElement
      include Log

      ATTRIBUTES = %i[
        klass
        name
        data_requirements
        supported_profiles
      ].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(values = {})
        log_debug 'Initializing DataElement model'

        @klass = values[:klass]
        @name = values[:name]
        @data_requirements = values[:data_requirements] || []
        @supported_profiles = values[:supported_profiles] || {}
      end

      def self.from_json(json, profiles)
        klass = json['class']
        name = json['name']
        ig_urls = json['mappings']['current']['qi_core_profiles'] || []
        us_core_urls = json['mappings']['current']['us_core_profiles'] || []
        requirements = json['mappings']['elements'] || []

        log_warn "Data element `#{name}` has no associated `#{Config.name}` profile(s) in the target `#{Config.name}` IG version" if ig_urls.empty?

        data_requirements = []
        supported_profiles = {}
        ig_urls.each do |ig_url|
          requirements.each do |requirement|
            data_requirement = Models::DataRequirement.from_requirement(requirement, ig_url, profiles)
            next if data_requirement.nil?

            data_requirements << data_requirement
            add_supported_profile(
              supported_profiles,
              data_requirement.resource,
              "#{Config.base_url}/StructureDefinition/#{data_requirement.ig_profile_id}",
              data_requirement.id
            )
          end
        end

        if ig_urls.empty?
          us_core_urls.each do |url|
            resource = resource_for_profile_url(url, requirements)
            if resource.nil?
              log_warn "Could not infer resource type for US Core profile `#{url}` on data element `#{name}`"
              next
            end

            requirements.select { |requirement| extract_resource(requirement) == resource }.each do |requirement|
              add_supported_profile(supported_profiles, resource, url, requirement)
            end
          end
        end

        new(
          klass: klass,
          name: name,
          data_requirements: data_requirements,
          supported_profiles: supported_profiles
        )
      end

      def to_json(*_args)
        profiles = []
        elements = []
        data_requirements.each do |requirement|
          elements << requirement.id
          profiles << "#{Config.base_url}/StructureDefinition/#{requirement.ig_profile_id}" unless requirement.ig_profile_id.nil?
        end

        {
          class: klass,
          name: name,
          mappings: {
            profiles: profiles.uniq,
            elements: elements
          }
        }
      end

      class << self
        private

        def add_supported_profile(supported_profiles, resource, profile_url, requirement)
          return if resource.blank? || profile_url.blank? || requirement.blank?

          supported_profiles[resource] ||= {}
          supported_profiles[resource][profile_url] ||= []
          supported_profiles[resource][profile_url] << requirement
          supported_profiles[resource][profile_url].uniq!
        end

        def resource_for_profile_url(profile_url, requirements)
          resources = requirements.map { |requirement| extract_resource(requirement) }.uniq
          return resources.first if resources.one?

          profile_id = profile_url.split('|').first.split('/').last
          normalized_profile_id = normalize_resource_name(profile_id)
          resources.find { |resource| normalized_profile_id.include?(normalize_resource_name(resource)) }
        end

        def extract_resource(requirement)
          requirement.split('.').first
        end

        def normalize_resource_name(name)
          name.downcase.gsub(/[^a-z0-9]/, '')
        end
      end
    end
  end
end
