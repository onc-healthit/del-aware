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
      ].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(values = {})
        log_debug 'Initializing DataElement model'

        @klass = values[:klass]
        @name = values[:name]
        @data_requirements = values[:data_requirements] || []
      end

      def self.from_json(json, profiles)
        klass = json['class']
        name = json['name']
        ig_urls = json['mappings']['current']['qi_core_profiles']
        requirements = json['mappings']['elements']

        log_warn "Data element `#{name}` has no associated `#{Config.name}` profile(s) in the target `#{Config.name}` IG version" if ig_urls.empty?

        data_requirements = []
        ig_urls.each do |ig_url|
          requirements.each do |requirement|
            data_requirement = Models::DataRequirement.from_requirement(requirement, ig_url, profiles)
            data_requirements << data_requirement unless data_requirement.nil?
          end
        end

        new(klass: klass, name: name, data_requirements: data_requirements)
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
    end
  end
end
