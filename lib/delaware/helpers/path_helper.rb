# frozen_string_literal: true

module Delaware
  module Helpers
    # Centralized file path handling logic
    # Provides methods to construct file paths used across the application
    module PathHelper
      CACHE_DIR = 'cache'

      def resource_output(base)
        File.join(base, 'input', 'resources')
      end

      def profiles_output(base)
        File.join(base, 'input', 'profiles')
      end

      def intros_output(base)
        File.join(base, 'input', 'intro-notes')
      end

      def pages_output(base)
        File.join(base, 'input', 'pages')
      end

      def structure_definition_profile_path(base, profile_id)
        File.join(profiles_output(base), "StructureDefinition-#{profile_id}.json")
      end

      def self.included(base)
        base.extend(self)
      end
    end
  end
end
