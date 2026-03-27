# frozen_string_literal: true

module Delaware
  module Models
    # Represents a FHIR "Profile".
    class Profile < FHIR::R4::StructureDefinition
      include Log
      include Delaware::Helpers::PathHelper

      ATTRIBUTES = %i[].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(values = {})
        log_debug "Initializing Profile model (id = #{values['id']})"

        super
      end

      # Initialize from the given JSON string.
      def self.from_json(contents)
        log_debug 'Initializing Profile from JSON'

        json = JSON.parse(contents)
        new(json)
      end

      # Initialize by fetching JSON for the given official URL.
      def self.from_url(url, retries = 3)
        return nil unless retries.positive?

        target_url = versioned_url(url, '.json')

        log_debug "Initializing Profile from URL #{target_url}"

        contents = RestClient.get(target_url, { accept: :json })
        json = JSON.parse(contents)
        profile = new(json)

        profile.save_to_cache(url)

        profile
      rescue StandardError => e
        log_error "Failed to resolve #{url}, #{e}"

        nil
      end

      def self.versioned_url(url, ending = '')
        url.gsub!('|', '%7C')
        if url.include?('%7C')
          version = url.split('%7C').last
          version = version.gsub(/.0$/, '') if version.ends_with?('.0')
          url.gsub('/StructureDefinition/', "/STU#{version}/StructureDefinition-").gsub(/%7C.*/, ending)
        else
          url
        end
      end

      # Initialize from a copy in the local cache.
      def self.from_cache(url)
        filename = url.gsub('/', '-').gsub('|', '%7C').gsub(':', '-')
        cache_path = File.join(CACHE_DIR, filename)
        return unless File.exist?(cache_path)

        log_debug "Found #{url} in cache"

        contents = File.read(cache_path)
        from_json(contents)
      end

      # Return from the given list if there is an id match
      def self.from_profiles(id, profiles)
        profiles&.values&.find { |p| p.id == id }
      end

      # Initialize from a copy from the target IG source.
      def self.from_working_dir(id, working_dir)
        return nil if working_dir.nil?

        output_path = structure_definition_profile_path(working_dir, id)
        if File.exist?(output_path)
          log_debug "Found #{id} in output"

          contents = File.read(output_path)
          return from_json(contents)
        end

        nil
      end

      # Attempt to initialize the profile defined by the given URL in
      # the following order:
      #
      # - If the required profile is not versioned
      #   - From IG loaded profiles (if param provided)
      #   - From local IG source (if param provided)
      # - From the local cache
      # - From the URL directly
      #
      # If a download is required, a copy of the profile will be written
      # to cache for future lookup.
      def self.resolve(url, profiles = nil, working_dir = nil)
        log_debug "Resolving Profile for #{url}"

        # Only look at self if no version is being specified
        unless url.include?('%7C') || url.include?('|')
          id = url.split('/').last

          # Try loaded profiles
          profile = from_profiles(id, profiles) unless profiles.nil?
          return profile unless profile.nil?

          # Try local IG source
          profile = from_working_dir(id, working_dir) unless working_dir.nil?
          return profile unless profile.nil?
        end

        # Try cache
        profile = from_cache(url)
        return profile unless profile.nil?

        # Load from URL
        from_url(url)
      end

      def save_to_cache(url)
        FileUtils.mkdir_p(CACHE_DIR)
        filename = url.gsub('/', '-').gsub('|', '%7C').gsub(':', '-')
        cache_path = File.join(CACHE_DIR, filename)

        log_debug "Saving #{url} to cache at #{cache_path}"

        File.write(cache_path, to_json)
      end

      def parent(profiles = {}, working_dir = nil)
        target = if baseDefinition.include?('us/core')
                   baseDefinition + "|#{Config.us_core_version}"
                 elsif baseDefinition.include?('http://hl7.org/fhir/StructureDefinition')
                   baseDefinition + "|#{Config.fhir_version}"
                 else
                   baseDefinition
                 end
        @parent ||= self.class.resolve(target, profiles, working_dir)
      end

      def differential_elements
        differential&.element
      end

      def snapshot_elements
        snapshot&.element
      end

      # Prefers snapshot elements (if they happen to exist), otherwise use
      # differential elements.
      def elements
        (snapshot_elements || differential_elements) || []
      end

      # Collect elements for this profile (and all ancestor profiles) which are considered "must have".
      def must_have_elements(profiles = {}, working_dir = nil)
        @must_have_elements ||= begin
          target_elements = []
          ancestor_definitions(profiles, working_dir, baseDefinition).each do |ancestor|
            ancestor.snapshot_elements&.each do |element|
              path = element.path.split('.').drop(1)
              if path.count > 1
                # Only include paths of multiple segments if this is a slice
                target_elements << element if element.mustSupport && element.id.include?(':') && element.min&.positive?
              elsif element.min&.positive?
                target_elements << element
              end
            end
            # Overwrite with updated short if one exists (i.e. don't overwrite shorts we've updated with tags)
            target_elements.uniq(&:id).map do |element|
              profiled_element = elements.find { |e| e.id == element.id }
              element.short = profiled_element.short unless profiled_element.nil?
              element
            end
          end
          target_elements
        end
      end

      # Collect elements for this profile (and the parent) tagged as a key element.
      def key_elements(profiles = {}, working_dir = nil)
        @key_elements ||= begin
          local_elements = tagged_elements('keyelement')
          parent_elements = parent(profiles, working_dir)&.tagged_elements('keyelement') || []

          (local_elements + parent_elements).uniq(&:id)
        end
      end

      def tagged_elements(tag = nil)
        tag = Config.tag_id if tag.nil?

        elements.select do |element|
          element.extension.any? { |e| e.url.downcase.ends_with?(tag) }
        end
      end

      private

      # Collect all base definition profiles (starting with the one provided), up to and
      # including one from US Core.
      def ancestor_definitions(profiles, working_dir, base_definition, results = [])
        return results if base_definition.nil?

        return results if [
          'http://hl7.org/fhir/StructureDefinition/Base',
          'http://hl7.org/fhir/StructureDefinition/DomainResource',
          'http://hl7.org/fhir/StructureDefinition/Resource'
        ].include?(base_definition)

        definition = self.class.resolve(base_definition, profiles, working_dir)

        return results if definition.nil?

        results << definition

        return results if base_definition.include?('us/core')

        ancestor_definitions(profiles, working_dir, definition.baseDefinition, results)
      end
    end
  end
end
