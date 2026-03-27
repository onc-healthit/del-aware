# frozen_string_literal: true

module Delaware
  class Generators
    # Generates an extension for tagging profile elements
    class Extension
      class << self
        def generate(base_output_dir)
          new(base_output_dir).generate
        end
      end

      attr_accessor :base_output_dir

      def initialize(base_output_dir)
        self.base_output_dir = base_output_dir
      end

      def template
        @template ||= File.read(File.join(__dir__, 'templates', 'extension.json.erb'))
      end

      def output
        raw_json = ERB.new(template, trim_mode: '-').result(binding)
        @output ||= JSON.pretty_generate(JSON.parse(raw_json))
      end

      def base_output_file_name
        "StructureDefinition-#{id}.json"
      end

      def tag
        Config.tag
      end

      def id
        Config.tag_id
      end

      def version
        Config.version
      end

      def fhir_version
        Config.fhir_version
      end

      def date
        DateTime.now.to_s
      end

      def base_url
        Config.base_url
      end

      def url
        "#{base_url}/StructureDefinition/#{id}"
      end

      def ig_name
        Config.name
      end

      def name
        title.gsub(/\s+/, '').gsub(/\W/, '')
      end

      def description
        "This extension is only used in the #{Config.name} Implementation Guide's Profile StructureDefinition elements."
      end

      def title
        "#{Config.name} #{tag} Extension"
      end

      def output_file_directory
        File.join(base_output_dir)
      end

      def output_file_name
        File.join(output_file_directory, base_output_file_name)
      end

      def resources
        data_element_list.by_resource
      end

      def generate
        FileUtils.mkdir_p(output_file_directory)
        File.write(output_file_name, output)
      end
    end
  end
end
