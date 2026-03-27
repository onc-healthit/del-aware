# frozen_string_literal: true

module Delaware
  # CLI handling.
  class CLI < Thor
    include Log

    check_unknown_options!

    def self.exit_on_failure?
      true
    end

    desc 'version', 'prints the current version'
    def version
      log_info "Current del-aware version: #{VERSION}"
    end

    desc 'apply', 'apply a DEL to an IG'
    option :config, type: :string, required: true, desc: 'location of the YAML config file for the IG'
    option :del, type: :string, required: true, desc: 'location of the DEL input file'
    option :ig, type: :string, required: true, desc: 'location of the IG source'
    option :gofsh, type: :boolean, desc: 'convert the IG output to FSH using GoFSH'
    option :modelinfo, type: :boolean, desc: 'generate a modelinfo file against the IG source using cfq-tooling'
    def apply
      # Load and parse config
      Config.from_file(options[:config])

      # Parse IG
      implementation_guide = Models::ImplementationGuide.from_local(options[:ig])

      # Parse DEL (using parsed profiles from IG)
      profiles = implementation_guide.profiles
      data_element_list = Models::DataElementList.from_json(File.read(options[:del]), profiles)

      # Apply the DEL
      implementation_guide.apply_del_tags(data_element_list)

      # Update version tags in profiles
      implementation_guide.update_profile_versions

      # Write the updated IG source to the target output location
      Helpers::FileLoader.save_profiles(options[:ig], implementation_guide.profiles)

      # Update version tags in resources and IG definition file
      implementation_guide.update_resource_versions(options[:ig])
      implementation_guide.update_ig_version(options[:ig])

      # Generate extensions
      implementation_guide.generate_extensions(options[:ig])

      # Generate capability statements
      implementation_guide.generate_capability_statements(options[:ig], data_element_list)

      # Generate tagged elements summary page
      # NOTE: Suppressed as of v1
      # implementation_guide.generate_tag_elements_page(options[:ig])

      # Generate profile intro pages
      implementation_guide.generate_profile_intro_pages(options[:ig])

      # Generate mapping table
      implementation_guide.generate_mapping_table(JSON.parse(File.read(options[:del])), options[:ig])

      # Convert IG output to FSH using GoFSH if specified
      if options[:gofsh]
        go_fsh = Services::GoFsh.new(options[:ig])
        go_fsh.execute
      end

      if options[:modelinfo]
        log_info 'Generating modelinfo file against the IG source'

        cqf_tooling = Services::CqfTooling.new
        input_path = File.join(options[:ig], 'input')
        resource_paths = 'profiles'
        modelinfo_output_path = options[:ig]
        cqf_tooling.generate_modelinfo(modelinfo_output_path, input_path, resource_paths)
      end

      puts 'Done!'
      puts "See #{options[:ig]} for results."
    rescue Error => e
      log_error "Error encountered: #{e.message}"

      exit 1
    end
  end
end
