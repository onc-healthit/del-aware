# frozen_string_literal: true

require 'fhir_models'

module Delaware
  class Generators
    # Generates a server capability statement
    class SearchParameter
      class << self
        def generate(profile, param, base_output_dir, metadata = nil)
          new(profile, param, base_output_dir, metadata).generate
        end
      end

      attr_accessor :profile, :param, :base_output_dir, :metadata

      def initialize(profile, param, base_output_dir, metadata = nil)
        self.profile = profile
        self.param = param
        self.base_output_dir = base_output_dir
        self.metadata = metadata
      end

      def output
        search_param = FHIR::R4::SearchParameter.new
        search_param.id = id
        search_param.url = url
        search_param.version = version
        search_param.name = name
        search_param.status = 'active'
        search_param.date = date
        search_param.description = description
        search_param.code = metadata.present? ? metadata[:code] : param
        search_param.base << base
        search_param.type = type
        search_param.expression = expression
        search_param.xpathUsage = 'normal'
        search_param.multipleOr = true
        search_param.multipleAnd = true

        if metadata&.key?(:comparator)
          comparator_result = comparator_with_extension(metadata)
          search_param.comparator = comparator_result[:comparators]

          search_param_hash = JSON.parse(search_param.to_json)

          search_param_hash = search_param_hash.each_with_object({}) do |(k, v), new_hash|
            new_hash[k] = v
            if k == 'comparator'
              new_hash['_comparator'] = comparator_result[:extensions]
            end
          end

          @output ||= JSON.pretty_generate(search_param_hash)
        else
          @output = JSON.pretty_generate(search_param)
        end
      end

      def base_output_file_name
        "SearchParameter-#{id}.json"
      end

      def id
        if metadata.present?
          "#{Config.ig_id}-#{profile.type.downcase}-#{metadata[:code]}"
        else
          "#{Config.ig_id}-#{profile.type.downcase}-#{param.gsub('_', '')}"
        end
      end

      def version
        Config.version
      end

      def fhir_version
        Config.fhir_version
      end

      def date
        Config.date
      end

      def base_url
        Config.base_url
      end

      def type
        if metadata.present?
          Delaware::Helpers::FhirResourceDetails.search_parameter_type(base, metadata)
        elsif %w[patient subject].include?(param)
          'reference'
        else
          'token'
        end
      end

      def expression
        # TODO: this needs to be more dynamic
        if metadata.present?
          return metadata[:expression].present? ? metadata[:expression] : "#{base}.#{metadata[:code]}"
        end

        return 'Task.for.where(resolve() is Patient)' if base == 'Task'

        return "#{base}.subject.where(resolve() is Patient)" if (param == 'patient') && FHIR.const_get(base)::SEARCH_PARAMS.include?('subject')

        return "#{base}.subject.where(resolve() is Patient)" if param == 'subject'

        return "#{base}.procedureReference.resolve().code" if param == 'procedure-code'

        return 'Resource.id' if param == '_id'

        path = Delaware::Helpers::FhirResourceDetails.path_for_search_param(profile.type, param)

        "#{base}.#{path}"
      end

      def comparator_with_extension(metadata)
        comparators = metadata[:comparator]

        return { comparators: [], extensions: [] } if comparators.blank?

        comparator_map = comparators.reduce({}, :merge)

        comparator_keys = comparator_map.keys.map(&:to_s)

        extensions = comparator_map.values.map do |expectation|
          {
            extension: [
              {
                url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                valueCode: expectation
              }
            ]
          }
        end

        { comparators: comparator_keys, extensions: extensions }
      end

      def base
        profile.type
      end

      def url
        "#{base_url}/SearchParameter/#{id}"
      end

      def name
        id.titleize.gsub(/\s+/, '')
      end

      def description
        "#{title} Search Parameter"
      end

      def title
        if metadata.present?
          "#{Config.name} #{profile.type} #{metadata[:code].camelize}"
        else
          "#{Config.name} #{profile.type} #{param.titleize}"
        end
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
