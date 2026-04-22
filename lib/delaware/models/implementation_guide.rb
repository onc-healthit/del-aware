# frozen_string_literal: true

module Delaware
  module Models
    # Represents an Implementation Guide.
    class ImplementationGuide
      include Log
      include Delaware::Helpers::PathHelper

      ATTRIBUTES = %i[
        profiles
      ].freeze

      attr_reader(*ATTRIBUTES)

      def initialize(values = {})
        log_debug 'Initializing ImplementationGuide model'

        @profiles = values[:profiles]
      end

      def apply_del_tags(data_element_list)
        log_info 'Applying DEL to IG profiles'

        # Remove previously existing tags
        profiles.each_value do |profile|
          profile.differential&.element&.each do |element|
            element.extension&.reject! { |ext| ext.url.downcase.ends_with? Config.tag_id }
            if element.short&.include?(Config.tag)
              element.short = element.short.gsub("(#{Config.tag})", '').strip.gsub(/\s+/, ' ')
            end
          end
        end

        # Add tags to elements that need them
        data_element_list.data_elements.each do |data_element|
          data_element.data_requirements.sort_by(&:id).each do |data_requirement|
            target = find_profile(data_requirement)
            if target.nil?
              log_warn "Could not find a profile for requirement `#{data_requirement.id}` on `#{data_requirement.url}`"
              next
            end
            element = find_element(target, data_requirement, profiles)
            if element.nil?
              log_warn "Could not find an element at `#{data_requirement.id}` for `#{data_element.klass} #{data_element.name}`"
              next
            end

            next if element.short&.include?(Config.tag)

            log_info "Adding tag Extension to `#{data_requirement.id}` in profile `#{target.id}`"
            log_debug "Applying tag to element `#{element.id}` in profile `#{target.id}`"
            element.extension ||= []
            element.extension << FHIR::R4::Extension.new({
                                                           url: "#{Config.base_url}/StructureDefinition/#{Config.tag_id}",
                                                           valueBoolean: true
                                                         })
            element.short = "(#{Config.tag}) #{element.short}".strip.gsub(/\s+/, ' ')
          end
        end
      end

      def update_profile_versions
        log_info 'Updating version tags in IG source'

        # Skip updating if version is nil
        if Config.version.nil?
          log_info 'Version is nil, skipping update of version tags'
          return
        end

        # Update profile versions
        profiles.each_value do |profile|
          if profile.version != Config.version
            log_info "Updating version tag for profile `#{profile.id}` to `#{Config.version}`"
            profile.version = Config.version
          end
        end
      end

      def update_resource_versions(output_path)
        log_info 'Updating version tags in resource files'

        resource_directory = File.join(output_path, 'input', 'resources')
        Dir.glob(File.join(resource_directory, 'StructureDefinition-*.{json,xml}')).each do |resource_file|
          log_info "Processing resource file: #{resource_file}"

          begin
            # Parse the resource file using fhir_models
            resource_contents = File.read(resource_file)
            resource = FHIR.from_contents(resource_contents)

            # Check if the resource has a version field
            if resource.respond_to?(:version) && !resource.version.nil?
              # Overwrite the version if it differs
              if resource.version == Config.version
                log_info "Version tag for resource `#{resource.id}` is already up-to-date"
              else
                log_info "Updating version tag for resource `#{resource.id}` to `#{Config.version}`"
                resource.version = Config.version

                # Write the updated resource back to the file
                File.write(resource_file, resource.to_json)
              end
            else
              log_warn "Resource file `#{resource_file}` does not have a version field or has a nil version; skipping update"
            end
          rescue StandardError => e
            log_error "Failed to update version for resource file `#{resource_file}`: #{e.message}"
          end
        end
      end

      def update_ig_version(output_path)
        log_info 'Updating version tag in IG definition file'

        input_directory = File.join(output_path, 'input')
        ig_def_filepath = Dir.glob(File.join(input_directory, "#{Config.ig_id}.*")).first

        if ig_def_filepath.nil?
          log_warn "No IG definition file found in #{input_directory}; skipping update"
          return
        end

        ig_def_extension = File.extname(ig_def_filepath).delete('.')
        log_info "Processing IG definition file: #{ig_def_filepath}"

        begin
          ig_def = FHIR.from_contents(File.read(ig_def_filepath))
          ig_def.version = Config.version

          ig_output = if ig_def_extension == 'json'
                        ig_def.to_json
                      elsif ig_def_extension == 'xml'
                        ig_def.to_xml
                      else
                        raise Error, "Unsupported file extension: #{ig_def_extension}"
                      end

          File.write(ig_def_filepath, ig_output)
          log_info "Updated version tag in IG definition file: #{ig_def_filepath}"
        rescue StandardError => e
          log_error "Failed to update version for IG definition file `#{ig_def_filepath}`: #{e.message}"
        end
      end

      def enforce_us_core_version_on_canonicals
        log_info "Ensuring US Core canonicals are pinned to #{Config.us_core_version} in profiles"
        profiles.each_value do |profile|
          # Helper to pin a canonical to US Core version
          pin = lambda { |url|
            return url if url.nil? || !url.include?('us/core')

            if url.include?('|')
              base, _ver = url.split('|', 2)
              "#{base}|#{Config.us_core_version}"
            else
              "#{url}|#{Config.us_core_version}"
            end
          }

          # pin baseDefinition
          profile.baseDefinition = pin.call(profile.baseDefinition)

          # pin profile and targetProfile in differential and snapshot
          [profile.differential&.element, profile.snapshot&.element].compact.flatten.each do |element|
            next if element.type.nil?

            element.type.each do |t|
              if t.profile
                t.profile = t.profile.map { |p| pin.call(p) }
              end
              if t.targetProfile
                t.targetProfile = t.targetProfile.map { |tp| pin.call(tp) }
              end
            end
          end
        end
      end

      def generate_extensions(base)
        Generators::Extension.generate(resource_output(base))
      end

      def generate_capability_statements(base, data_element_list)
        Generators::CapabilityStatementServer.generate(profiles, data_element_list, resource_output(base))
        Generators::CapabilityStatementClient.generate(profiles, data_element_list, resource_output(base))
      end

      def generate_tag_elements_page(base)
        Generators::TagElements.generate(profiles, base, pages_output(base))
      end

      def generate_profile_intro_pages(base)
        profiles.each_value do |profile|
          Generators::ProfileIntro.generate(profile, profiles, base, intros_output(base))
        end
      end

      def generate_mapping_table(mappings, base)
        Generators::MappingTable.generate(profiles, mappings, base)
      end

      def self.from_local(local_path)
        log_info "Loading source IG from local file or directory at #{local_path}"

        raise Error, "Local IG path is invalid: #{local_path}" unless File.directory?(local_path)

        profiles = Helpers::FileLoader.load_profiles(local_path)

        log_info "#{profiles.count} profiles loaded"

        new(profiles: profiles)
      end

      private

      def find_profile(data_requirement)
        # Try direct id match
        direct = profiles.values.find { |p| p.id == data_requirement.ig_profile_id }
        return direct unless direct.nil?

        # Try base profile
        base = profiles[data_requirement.resource]
        return base unless base.nil?

        nil
      end

      # Given a data requirement, return the matching element on the target
      # profile. If no match currently exists, look at the parent profile for
      # a match - make a minimal copy of that element, insert the copy at the
      # correct index in the target profile differential, and return that element.
      def find_element(target, data_requirement, profiles)
        element = target.differential&.element&.find { |e| e.id == data_requirement.id }
        return element unless element.nil?

        # If no match, look at the parent
        target_elements = target.differential.element
        parent_elements = target.parent(profiles).elements
        parent_element_index = parent_elements&.find_index { |e| e.id == data_requirement.id }
        parent_element = parent_element_index && parent_elements[parent_element_index]
        unless parent_element.nil?
          # Construct minimal element copy
          missing_element = FHIR::R4::ElementDefinition.new
          missing_element.id = parent_element.id
          missing_element.path = parent_element.path
          missing_element.short = parent_element.short.gsub('𝗔𝗗𝗗𝗜𝗧𝗜𝗢𝗡𝗔𝗟 𝗨𝗦𝗖𝗗𝗜: ', '')
          is_slice_dec = parent_element.id.include?(':') && !parent_element.id.split(':').last.include?('.')
          missing_element.sliceName = parent_element.id.split(':').last if is_slice_dec
          unless parent_element.slicing.nil?
            missing_element.slicing = parent_element.slicing
            missing_element.slicing.discriminator.first.type = 'pattern'
          end

          # Differenial element order matters; figure out where to insert
          insert_index = nil

          # If this thing looks like a slice, we will look at id. Otherwise, we'll look at
          # path. This is to ensure slice declarations happen before slice child elements.
          is_slice = missing_element.id.include?(':')

          # Look at parent elements and note elements that are supposed to appear
          # before and after the missing element.
          before = parent_elements[0...parent_element_index].map { |e| is_slice ? e.id : e.path }
          after = parent_elements[(parent_element_index + 1)..].map { |e| is_slice ? e.id : e.path }

          # Build index of current element ids
          indices = {}
          target_elements.each_with_index { |e, i| is_slice ? indices[e.id] = i : indices[e.path] = i }

          # Prefer nearest predecessor. If there is a match, set insert index
          # so that the new element is inserted after the match.
          before.reverse_each do |path|
            if indices.key?(path)
              insert_index = indices[path] + 1
              break
            end
          end

          # Otherwise use the nearest successor. If there is a match, set
          # insert index so that the new element is inserted before the match.
          if insert_index.nil?
            after.each do |path|
              if indices.key?(path)
                insert_index = indices[path]
                break
              end
            end
          end

          # If no matches were found, default to inserting at the start.
          insert_index = 0 if insert_index.nil?

          target.differential.element.insert(insert_index, missing_element)

          return missing_element
        end

        nil
      end
    end
  end
end
