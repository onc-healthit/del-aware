# frozen_string_literal: true

module Delaware
  class Generators
    # Generates a server capability statement
    class CapabilityStatementServer
      class << self
        def generate(profiles, data_element_list, base_output_dir)
          new(profiles, data_element_list, base_output_dir).generate
        end
      end

      attr_accessor :profiles, :data_element_list, :base_output_dir

      def initialize(profiles, data_element_list, base_output_dir)
        self.profiles = profiles
        self.data_element_list = data_element_list
        self.base_output_dir = base_output_dir
      end

      def output
        # Supported Resources
        resources = []
        data_element_list.by_resource.each_key do |type|
          resource = FHIR::R4::CapabilityStatement::Rest::Resource.new
          resource.extension << FHIR::R4::Extension.new({
                                                          url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                          valueCode: 'SHALL'
                                                        })
          resource.type = type
          resource.supportedProfile = data_element_list.by_resource[type].keys.map do |profile|
            "#{base_url}/StructureDefinition/#{profile}"
          end
          resource.referencePolicy = ['resolves']

          # Interactions

          code_interaction = FHIR::R4::CapabilityStatement::Rest::Resource::Interaction.new
          code_interaction.code = 'read'
          code_interaction.extension << FHIR::R4::Extension.new({
                                                                  url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                  valueCode: 'SHALL'
                                                                })
          resource.interaction << code_interaction

          search_interaction = FHIR::R4::CapabilityStatement::Rest::Resource::Interaction.new
          search_interaction.code = 'search-type'
          search_interaction.extension << FHIR::R4::Extension.new({
                                                                    url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                    valueCode: interaction_expectation(type, search_interaction.code)
                                                                  })
          resource.interaction << search_interaction

          # Search Parameters

          search_params = []

          if requires_id_search?(type)
            param = FHIR::R4::CapabilityStatement::Rest::Resource::SearchParam.new
            param.name = '_id'
            param.definition = search_param_url(type, '_id')
            param.type = 'token'
            param.documentation = 'The client **SHALL** provide an id value.'
            param.extension << FHIR::R4::Extension.new({
                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                         valueCode: 'SHALL'
                                                       })

            search_params << param
          end

          if patient_search_parameter(type).present?
            param = FHIR::R4::CapabilityStatement::Rest::Resource::SearchParam.new
            param.name = patient_search_parameter(type)
            param.definition = search_param_url(type, patient_search_parameter(type))
            param.type = 'reference'
            param.documentation = 'The client **SHALL** provide an id value for the reference.'

            param.extension << FHIR::R4::Extension.new({
                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                         valueCode: patient_search_expectation(type)
                                                       })

            search_params << param

            search_combinations = search_parameter_combination(type)
            if search_combinations.any?
              search_combinations.each do |metadata|
                combo_extension = FHIR::R4::Extension.new({
                                                            url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination'
                                                          })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                       valueCode: metadata[:expectation]
                                                                     })
                metadata[:code].each do |code|
                  combo_extension.extension << FHIR::R4::Extension.new({
                                                                         url: 'required',
                                                                         valueString: code
                                                                       })
                end

                resource.extension << combo_extension
              end
            else
              if requires_category_search?(type)
                combo_extension = FHIR::R4::Extension.new({
                                                            url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination'
                                                          })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                       valueCode: 'SHALL'
                                                                     })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'required',
                                                                       valueString: patient_search_parameter(type)
                                                                     })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'required',
                                                                       valueString: 'category'
                                                                     })

                resource.extension << combo_extension
              end

              if requires_status_search?(type)
                combo_extension = FHIR::R4::Extension.new({
                                                            url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination'
                                                          })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                       valueCode: 'SHALL'
                                                                     })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'required',
                                                                       valueString: patient_search_parameter(type)
                                                                     })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'required',
                                                                       valueString: 'status'
                                                                     })

                resource.extension << combo_extension
              end

              if code_search_parameter(type).present?
                combo_extension = FHIR::R4::Extension.new({
                                                            url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination'
                                                          })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                       valueCode: 'SHALL'
                                                                     })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'required',
                                                                       valueString: patient_search_parameter(type)
                                                                     })
                combo_extension.extension << FHIR::R4::Extension.new({
                                                                       url: 'required',
                                                                       valueString: code_search_parameter(type)
                                                                     })

                resource.extension << combo_extension
              end

              if search_parameter_metadata(type).present?
                params = search_parameter_metadata(type, exclude_patient: true)
                params.each do |metadata|
                  combo_extension = FHIR::R4::Extension.new({
                                                              url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-search-parameter-combination'
                                                            })
                  combo_extension.extension << FHIR::R4::Extension.new({
                                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                         valueCode: 'SHALL'
                                                                       })
                  combo_extension.extension << FHIR::R4::Extension.new({
                                                                         url: 'required',
                                                                         valueString: patient_search_parameter(type)
                                                                       })
                  combo_extension.extension << FHIR::R4::Extension.new({
                                                                         url: 'required',
                                                                         valueString: metadata[:code]
                                                                       })

                  resource.extension << combo_extension
                end
              end
            end
          end

          conformance = patient_search_parameter(type).present? ? 'MAY' : 'SHALL'

          if requires_category_search?(type)
            param = FHIR::R4::CapabilityStatement::Rest::Resource::SearchParam.new
            param.name = 'category'
            param.definition = search_param_url(type, 'category')
            param.type = 'token'
            param.documentation = "The client **#{conformance}** provide a category."
            param.extension << FHIR::R4::Extension.new({
                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                         valueCode: conformance
                                                       })

            search_params << param
          end

          if requires_status_search?(type)
            param = FHIR::R4::CapabilityStatement::Rest::Resource::SearchParam.new
            param.name = 'status'
            param.definition = search_param_url(type, 'status')
            param.type = 'token'
            param.documentation = "The client **#{conformance}** provide a status."
            param.extension << FHIR::R4::Extension.new({
                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                         valueCode: conformance
                                                       })

            search_params << param
          end

          if code_search_parameter(type).present?
            param = FHIR::R4::CapabilityStatement::Rest::Resource::SearchParam.new
            param.name = code_search_parameter(type)
            param.definition = search_param_url(type, code_search_parameter(type))
            param.type = 'token'
            param.documentation = "The client **#{conformance}** provide a code value."
            param.extension << FHIR::R4::Extension.new({
                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                         valueCode: conformance
                                                       })

            search_params << param
          end

          if search_parameter_metadata(type).present?
            params = search_parameter_metadata(type, exclude_patient: true)
            params.each do |metadata|
              param = FHIR::R4::CapabilityStatement::Rest::Resource::SearchParam.new
              param.name = metadata[:code]
              param.definition = search_param_url(type, param.name)
              param.type = search_parameter_type(type, metadata)
              param.documentation = "The client **#{conformance}** provide a #{param.type} value."
              param.extension << FHIR::R4::Extension.new({
                                                           url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                           valueCode: conformance
                                                         })

              search_params << param
            end
          end

          resource.searchParam = search_params

          resources << resource
        end

        # Rest

        rest = FHIR::R4::CapabilityStatement::Rest.new
        rest.mode = mode
        rest.documentation = rest_documentation
        rest.resource = resources.sort_by(&:type)

        transaction_interaction = FHIR::R4::CapabilityStatement::Rest::Resource::Interaction.new
        transaction_interaction.code = 'transaction'
        transaction_interaction.extension << FHIR::R4::Extension.new({
                                                                       url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                       valueCode: 'MAY'
                                                                     })
        rest.interaction << transaction_interaction

        batch_interaction = FHIR::R4::CapabilityStatement::Rest::Resource::Interaction.new
        batch_interaction.code = 'batch'
        batch_interaction.extension << FHIR::R4::Extension.new({
                                                                 url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                 valueCode: 'MAY'
                                                               })
        rest.interaction << batch_interaction

        search_system_interaction = FHIR::R4::CapabilityStatement::Rest::Resource::Interaction.new
        search_system_interaction.code = 'search-system'
        search_system_interaction.extension << FHIR::R4::Extension.new({
                                                                         url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                         valueCode: 'MAY'
                                                                       })
        rest.interaction << search_system_interaction

        history_system_interaction = FHIR::R4::CapabilityStatement::Rest::Resource::Interaction.new
        history_system_interaction.code = 'history-system'
        history_system_interaction.extension << FHIR::R4::Extension.new({
                                                                          url: 'http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation',
                                                                          valueCode: 'MAY'
                                                                        })
        rest.interaction << history_system_interaction

        # Capability Statement

        statement = FHIR::R4::CapabilityStatement.new
        statement.id = id
        statement.url = url
        statement.version = version
        statement.name = name
        statement.title = title
        statement.status = 'active'
        statement.experimental = false
        statement.date = date
        statement.description = description
        statement.kind = 'requirements'
        statement.fhirVersion = fhir_version
        statement.format = %w[json]
        statement.implementationGuide = [base_url]
        statement.rest << rest

        @output ||= JSON.pretty_generate(statement)
      end

      def base_output_file_name
        "CapabilityStatement-#{id}.json"
      end

      def mode
        'server'
      end

      def id
        "#{Config.ig_id}-#{mode}"
      end

      def ig_name
        Config.name
      end

      def version
        Config.version
      end

      def fhir_version
        Config.fhir_version
      end

      def base_url
        Config.base_url
      end

      def url
        "#{base_url}/CapabilityStatement/#{id}"
      end

      def name
        title.gsub(/\s+/, '').gsub(/\W/, '')
      end

      def description
        Delaware::Helpers::ContentLoader.server_capability_statement_description
      end

      def rest_documentation
        Delaware::Helpers::ContentLoader.server_capability_statement_rest_documentation
      end

      def title
        "#{ig_name} #{mode.humanize} CapabilityStatement"
      end

      def date
        Config.date
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

      def search_param_url(resource, param)
        "#{base_url}/SearchParameter/#{Config.ig_id}-#{resource.downcase}-#{param.gsub('_', '')}"
      end

      def requires_id_search?(resource)
        Delaware::Helpers::FhirResourceDetails.requires_id_search?(resource)
      end

      def requires_category_search?(resource)
        Delaware::Helpers::FhirResourceDetails.requires_category_search?(resource)
      end

      def requires_status_search?(resource)
        Delaware::Helpers::FhirResourceDetails.requires_status_search?(resource)
      end

      def patient_search_parameter(resource)
        Delaware::Helpers::FhirResourceDetails.patient_search_parameter(resource)
      end

      def patient_search_expectation(resource)
        Delaware::Helpers::FhirResourceDetails.optional_patient_search?(resource) ? 'MAY' : 'SHALL'
      end

      def code_search_parameter(resource)
        return nil if Delaware::Helpers::FhirResourceDetails.suppress_code_search?(resource)

        primary_code_path = Delaware::Helpers::FhirResourceDetails.primary_code_path(profiles, resource)
        Delaware::Helpers::FhirResourceDetails.pcp_element_search_parameter(resource, primary_code_path)
      end

      def search_parameter_metadata(resource, exclude_patient: false)
        params = Delaware::Helpers::FhirResourceDetails.search_parameter_metadata(resource)
        exclude_patient ? params.select { |p| p[:code] != 'patient' } : params
      end

      def search_parameter_combination(resource)
        Delaware::Helpers::FhirResourceDetails.search_parameter_combination(resource)
      end

      def search_parameter_type(resource, metadata)
        Delaware::Helpers::FhirResourceDetails.search_parameter_type(resource, metadata)
      end

      def interaction_expectation(resource_type, interaction_code)
        Delaware::Helpers::FhirResourceDetails.interaction_expectation(resource_type, interaction_code)
      end

      def generate
        FileUtils.mkdir_p(output_file_directory)

        # Create supporting SearchParameters
        profiles.each_value do |profile|
          resource = profile.type
          patient_param = patient_search_parameter(resource)
          code_param = code_search_parameter(resource)
          search_param_metadata = search_parameter_metadata(resource)

          SearchParameter.generate(profile, '_id', base_output_dir) if requires_id_search?(resource)
          SearchParameter.generate(profile, 'category', base_output_dir) if requires_category_search?(resource)
          SearchParameter.generate(profile, 'status', base_output_dir) if requires_status_search?(resource)
          SearchParameter.generate(profile, patient_param, base_output_dir) unless patient_param.nil?
          SearchParameter.generate(profile, code_param, base_output_dir) unless code_param.nil?

          next unless search_param_metadata.present?

          search_param_metadata.each do |metadata|
            SearchParameter.generate(profile, nil, base_output_dir, metadata)
          end
        end

        File.write(output_file_name, output)
      end
    end
  end
end
