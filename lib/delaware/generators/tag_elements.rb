# frozen_string_literal: true

module Delaware
  class Generators
    # Generates a markdown summary page of all elements tagged.
    class TagElements
      class << self
        def generate(profiles, working_dir, base_output_dir)
          new(profiles, working_dir, base_output_dir).generate
        end
      end

      attr_accessor :profiles, :working_dir, :base_output_dir

      def initialize(profiles, working_dir, base_output_dir)
        self.profiles = profiles
        self.working_dir = working_dir
        self.base_output_dir = base_output_dir
      end

      def template
        @template ||= File.read(File.join(__dir__, 'templates', 'tag_elements.md.erb'))
      end

      def output
        @output ||= ERB.new(template, trim_mode: '-').result(binding)
      end

      # TODO: This is hard coded for QI-Core. Swap out tag for something more generic.
      def prefix
        # tag.downcase
        'qi'
      end

      def base_output_file_name
        "#{prefix}-elements.md"
      end

      def tag
        Config.tag
      end

      def tags
        by_profile = []
        profiles.values.sort_by(&:title).each do |profile|
          # must_have_elements = profile.must_have_elements(profiles, working_dir)
          key_elements = profile.key_elements(profiles, working_dir)
          tag_elements = profile.tagged_elements(Config.tag_id)

          pc_path = Delaware::Helpers::FhirResourceDetails.primary_code_path(profiles, profile.type)

          by_profile << {
            title: profile.title,
            link: "StructureDefinition-#{profile.id}.html",
            pc_path: pc_path,
            # NOTE: suppressing this for IG v1
            must_have_elements: [], # format_elements(must_have_elements, profile),
            key_elements: format_elements(key_elements, profile),
            tag_elements: format_elements(tag_elements, profile)
          }
        end
        by_profile
      end

      def output_file_directory
        File.join(base_output_dir)
      end

      def output_file_name
        File.join(output_file_directory, base_output_file_name)
      end

      def generate
        FileUtils.mkdir_p(output_file_directory)
        File.write(output_file_name, output)
      end

      private

      def format_elements(elements, profile)
        elements.map do |element|
          segments = element.id.split('.')
          target = if segments.count > 1
                     segments.drop(1).join('.')
                   else
                     segments.first
                   end
          next if target.blank?

          short = element.short&.gsub('|', '\|') || profile.description
          {
            target: target,
            short: short
          }
        end
        .compact
        .uniq
      end
    end
  end
end
