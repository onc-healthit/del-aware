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
    end
  end
end
