# frozen_string_literal: true

module Delaware
  module Models
    # Represents a data requirement.
    class DataRequirement
      include Log

      ATTRIBUTES = %i[
        id
        resource
        ig_profile_id
        url
      ].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(values = {})
        log_debug 'Initializing DataRequirement model'

        @id = values[:id]
        @resource = values[:resource]
        @ig_profile_id = values[:ig_profile_id]
        @url = values[:url]
      end

      def self.from_requirement(requirement, ig_url, profiles)
        resource = extract_resource(requirement)
        profile_id = ig_profile_id(resource, ig_url, profiles)
        return nil if profile_id.nil?

        new(
          id: requirement,
          resource: resource,
          ig_profile_id: profile_id,
          url: ig_url
        )
      end

      class << self
        private

        # `Observation.code` -> `Observation`
        def extract_resource(requirement)
          log_debug "Extracting resource from requirement: #{requirement}"

          requirement.split('.').first
        end

        def ig_profile_id(resource, ig_url, profiles)
          # If the resource matches the URL, return the id
          profile = profiles.values.find { |p| p.url.downcase == ig_url.downcase }

          if profile.nil?
            log_error "No match found for #{ig_url} in the parsed IG profiles"

            return nil
          end

          return nil unless resource == profile.type

          profile.id
        end
      end
    end
  end
end
