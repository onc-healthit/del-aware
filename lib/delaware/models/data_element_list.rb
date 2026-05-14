# frozen_string_literal: true

module Delaware
  class DataElementListParseError < Error; end

  module Models
    # Represents a data element list.
    class DataElementList
      include Log

      ATTRIBUTES = %i[
        name
        data_elements
      ].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(values = {})
        log_debug 'Initializing DataElementList model'

        @name = values[:name] || 'Data Element List'
        @data_elements = values[:data_elements] || []
      end

      def self.from_json(json, profiles)
        log_info 'Loading DEL from JSON source'

        data_elements = JSON.parse(json).map do |data_element|
          DataElement.from_json(data_element, profiles)
        end

        new(data_elements: data_elements)
      end

      def to_json(*_args)
        data_elements.map(&:to_json).to_json
      end

      # Returns a representation of the data element list organized by resource, e.g.
      #
      # {
      #   'AdverseEvent': {               // Resource
      #     'qicore-adverseevent': [      // Profiled resource id
      #         'AdverseEvent.event',     // Requirement(s)
      #       ]
      #     },
      #   ],
      # }
      def by_resource
        resources = {}
        data_elements.each do |data_element|
          data_element.data_requirements.each do |data_requirement|
            if data_requirement.resource.blank? ||
               data_requirement.id.blank? ||
               data_requirement.ig_profile_id.blank?
              next
            end

            resources[data_requirement.resource] = {} unless resources.key?(data_requirement.resource)

            unless resources[data_requirement.resource].key?(data_requirement.ig_profile_id)
              resources[data_requirement.resource][data_requirement.ig_profile_id] = []
            end

            resources[data_requirement.resource][data_requirement.ig_profile_id] << data_requirement.id
            resources[data_requirement.resource][data_requirement.ig_profile_id].uniq!
          end
        end
        resources
      end

      # Returns CapabilityStatement supported profiles organized by FHIR resource.
      # Profile keys are full canonical URLs because supportedProfile may point to
      # profiles outside the generated IG, such as US Core profiles.
      def supported_profiles_by_resource
        resources = {}
        data_elements.each do |data_element|
          if data_element.supported_profiles.present?
            merge_supported_profiles(resources, data_element.supported_profiles)
          else
            merge_local_data_requirements(resources, data_element.data_requirements)
          end
        end
        resources
      end

      private

      def merge_supported_profiles(resources, supported_profiles)
        supported_profiles.each do |resource, profiles|
          profiles.each do |profile_url, requirements|
            requirements.each do |requirement|
              add_profile_requirement(resources, resource, profile_url, requirement)
            end
          end
        end
      end

      def merge_local_data_requirements(resources, data_requirements)
        data_requirements.each do |data_requirement|
          if data_requirement.resource.blank? ||
             data_requirement.id.blank? ||
             data_requirement.ig_profile_id.blank?
            next
          end

          add_profile_requirement(
            resources,
            data_requirement.resource,
            "#{Config.base_url}/StructureDefinition/#{data_requirement.ig_profile_id}",
            data_requirement.id
          )
        end
      end

      def add_profile_requirement(resources, resource, profile_url, requirement)
        return if resource.blank? || profile_url.blank? || requirement.blank?

        resources[resource] ||= {}
        resources[resource][profile_url] ||= []
        resources[resource][profile_url] << requirement
        resources[resource][profile_url].uniq!
      end
    end
  end
end
