# frozen_string_literal: true

module Delaware
  class Generators
    # Generates a markdown page containing mapping information.
    class MappingTable
      class << self
        def generate(profiles, mappings, base_output_dir)
          new(profiles, mappings, base_output_dir).generate
        end
      end

      attr_accessor :profiles, :mappings, :base_output_dir

      def initialize(profiles, mappings, base_output_dir)
        self.profiles = profiles
        self.mappings = mappings
        self.base_output_dir = base_output_dir
      end

      def base_output_file_name
        'mapping-table.md'
      end

      def template
        @template ||= File.read(File.join(__dir__, 'templates', 'mapping-table.md.erb'))
      end

      def output
        @output ||= ERB.new(template, trim_mode: '-').result(binding)
      end

      def output_file_directory
        File.join(base_output_dir, 'input/includes')
      end

      def output_file_name
        File.join(output_file_directory, base_output_file_name)
      end

      def elements_by_bucket(bucket, mode)
        bucket_mappings = mappings.select { |m| m['bucket'] == bucket }
        bucket_classes = {}
        bucket_mappings.each do |mapping|
          class_name = mapping['class']
          bucket_classes[class_name] = {} unless bucket_classes.key?(class_name)

          element_name = mapping['name']
          bucket_classes[class_name][element_name] = []
          elements = mapping['mappings']['elements']

          # Grab QI profiles
          qi_core_profile_urls = mapping['mappings'][mode]['qi_core_profiles']
          qi_core_profiles = []
          qi_core_profile_urls.each do |url|
            profile = Delaware::Models::Profile.resolve(url, profiles)

            title = if mode == 'current'
                      profile.title
                    else
                      "#{profile.title} (#{profile.version})" # Include version in label
                    end

            link = if mode == 'current'
                     "StructureDefinition-#{profile.id}.html"
                   else
                     Delaware::Models::Profile.versioned_url(url, '.html').gsub('.json', '')
                   end

            profile = {
              title: title,
              link: link
            }

            qi_core_profiles << profile
          end

          # Grab US Core profiles
          us_core_profile_urls = mapping['mappings'][mode]['us_core_profiles']
          us_core_profiles = []
          us_core_profile_urls.each do |url|
            profile = Delaware::Models::Profile.resolve(url)

            profile = {
              title: "#{profile.title} (#{profile.version})", # Include version in label
              link: Delaware::Models::Profile.versioned_url(url, '.html').gsub('.json', '')
            }

            us_core_profiles << profile
          end

          # Self IG takes precedent over US Core. TODO: Make this behavior configurable?
          us_core_profiles = [] unless qi_core_profiles.empty?

          bucket_classes[class_name][element_name] = {
            elements: elements,
            qi_core_profiles: qi_core_profiles,
            us_core_profiles: us_core_profiles
          }
        end
        bucket_classes
      end

      def first_bucket
        elements_by_bucket(1, 'current')
      end

      def second_bucket
        elements_by_bucket(2, 'future')
      end

      def third_bucket
        elements_by_bucket(3, 'future')
      end

      def in_scope_data_elements
        first_bucket
      end

      def out_of_scope_data_elements
        second_bucket.merge(third_bucket)
      end

      def in_scope_profile_urls
        profile_urls = []
        mappings.each do |mapping|
          profile_urls.concat(mapping['mappings']['current']['qi_core_profiles'])
        end
        profile_urls.uniq
      end

      def in_scope_profiles
        results = []
        in_scope_profile_urls.map do |url|
          profile = Delaware::Models::Profile.resolve(url, profiles)
          results << {
            title: profile.title,
            link: "StructureDefinition-#{profile.id}.html"
          }
        end
        results
      end

      def out_of_scope_profile_urls
        all_urls = profiles.values.map(&:url)
        all_urls - in_scope_profile_urls
      end

      def out_of_scope_profiles
        results = []
        out_of_scope_profile_urls.map do |url|
          profile = Delaware::Models::Profile.resolve(url, profiles)
          results << {
            title: profile.title,
            link: "StructureDefinition-#{profile.id}.html"
          }
        end
        results
      end

      def generate
        FileUtils.mkdir_p(output_file_directory)
        File.write(output_file_name, output)
      end
    end
  end
end
