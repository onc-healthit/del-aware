# frozen_string_literal: true

require 'fhir_models'

module Delaware
  # Helpers
  module Helpers
    # Helpful details on FHIR resource types
    module FhirResourceDetails
      INTERACTION_EXPECTATION = {
        'Organization' => {
          'search-type' => 'MAY'
        }
      }.freeze

      def self.interaction_expectation(resource_type, interaction_code)
        resource = INTERACTION_EXPECTATION[resource_type]
        return 'SHALL' unless resource.present?

        resource[interaction_code] || 'SHALL'
      end

      def self.optional_patient_search?(resource_type)
        %w[
          CarePlan
          CareTeam
          MedicationRequest
          Observation
        ].include?(resource_type)
      end

      def self.patient_search_parameter(resource_type)
        if FHIR.const_get(resource_type)::SEARCH_PARAMS.include?('patient')
          'patient'
        elsif FHIR.const_get(resource_type)::SEARCH_PARAMS.include?('subject')
          'subject'
        end
      end

      # NOTE: may return the wrong value if
      # - the primary code path is not `code`, there is a `code` search parameter that doesn't point to it, or
      # - the dasherized naming convention doesn't hold
      # This has been checked and doesn't apply to profiles at this time, but may not be general
      def self.pcp_element_search_parameter(resource_type, element)
        return unless element.present?

        if FHIR.const_get(resource_type)::SEARCH_PARAMS.include?('code')
          'code'
        else
          element.underscore.dasherize
        end
      end

      def self.requires_id_search?(resource_type)
        %w[
          Encounter
          Patient
          Practitioner
          Location
          PractitionerRole
          QuestionnaireResponse
          RelatedPerson
          ServiceRequest
        ].include?(resource_type)
      end

      def self.requires_category_search?(resource_type)
        %w[
          Condition
          DiagnosticReport
          Observation
          ServiceRequest
        ].include? resource_type
      end

      def self.requires_status_search?(resource_type)
        %w[
          Immunization
          MedicationAdministration
          MedicationDispense
          Procedure
          Task
          Observation
        ].include? resource_type
      end

      def self.suppress_code_search?(resource_type)
        %w[
          Claim
          PractitionerRole
        ].include? resource_type
      end

      NON_STANDARD_SEARCH_PARAMETER_PATHS = {
        'Observation' => { 'patient' => 'subject' },
        'DiagnosticReport' => { 'patient' => 'subject' },
        'Encounter' => { 'patient' => 'subject' },
        'Goal' => { 'patient' => 'subject' },
        'Coverage' => { 'patient' => 'beneficiary' },
        'DeviceRequest' => {
          'patient' => 'subject',
          'code' => 'code.as(CodeableConcept)',
          'do-not-perform' => "extension.where(url = 'http://hl7.org/fhir/5.0/StructureDefinition/extension-DeviceRequest.doNotPerform').value"
        },
        'ServiceRequest' => { 'patient' => 'subject', 'do-not-perform' => 'doNotPerform' },
        'MedicationAdministration' => { 'patient' => 'subject', 'code' => 'medication.as(CodeableConcept)' },
        'MedicationDispense' => { 'patient' => 'subject' },
        'MedicationRequest' => { 'patient' => 'subject', 'do-not-perform' => 'doNotPerform' },
        'MedicationStatement' => { 'patient' => 'subject', 'code' => 'medication.as(CodeableConcept)' },
        'Condition' => { 'patient' => 'subject' },
        'Procedure' => { 'patient' => 'subject' },
        'Task' => { 'subject' => 'for' },
        'Immunization' => { 'vaccine-code' => 'vaccineCode' },
        'ImagingStudy' => { 'procedure-code' => 'procedureReference.code' },
        'ImmunizationEvaluation' => { 'target-disease' => 'targetDisease' },
        'ImmunizationRecommendation' => { 'recommendation-vaccine-code' => 'recommendation.vaccineCode' }
      }.freeze

      def self.path_for_search_param(resource_type, search_param)
        non_standard = NON_STANDARD_SEARCH_PARAMETER_PATHS.dig(resource_type, search_param)

        non_standard || search_param.gsub('-', '.')
      end

      # Pre v7, the primaryCodePath extension isn't used, so keep a list of what PCP
      # exists for each resource type. TODO: can we look at elements and figure
      # this out automatically?
      PRIMARY_CODE_PATHS = {
        'AdverseEvent' => 'event',
        'CarePlan' => 'category',
        'CareTeam' => 'status',
        'Claim' => 'type',
        'ClaimResponse' => 'type',
        'Communication' => 'topic',
        'CommunicationRequest' => 'category',
        'Condition' => 'code',
        'Device' => 'type',
        'DeviceRequest' => 'codeCodeableConcept',
        'DeviceUseStatement' => 'deviceType',
        'Observation' => 'code',
        'DiagnosticReport' => 'code',
        'Encounter' => 'type',
        'Flag' => 'code',
        'PractitionerRole' => 'code',
        'ImagingStudy' => 'procedureCode',
        'ImmunizationEvaluation' => 'targetDisease',
        'ImmunizationRecommendation' => 'recommendationVaccineCode',
        'ServiceRequest' => 'code',
        'Medication' => 'code',
        'MedicationAdministration' => 'medicationCodeableConcept',
        'MedicationStatement' => 'medicationCodeableConcept',
        'NutritionOrder' => 'type',
        'QuestionnaireResponse' => 'questionnaire',
        'Substance' => 'code',
        'Task' => 'code'
      }.freeze

      def self.primary_code_path(profiles, resource_type)
        if Config.stu_version >= 7
          primary_code_path = nil
          profiles.values.select { |p| p.type == resource_type }.each do |profile|
            path = profile.extension.find { |ext| ext.url.ends_with?('primaryCodePath') }&.value
            primary_code_path = path unless path.nil?
          end
          primary_code_path
        else

          # Fall back if primaryCodePath not available in this IG version
          PRIMARY_CODE_PATHS[resource_type]
        end
      end

      DEFAULT_COMPARATORS = [
        {
          eq: 'MAY',
          ne: 'MAY',
          gt: 'SHALL',
          ge: 'SHALL',
          lt: 'SHALL',
          le: 'SHALL',
          sa: 'MAY',
          eb: 'MAY',
          ap: 'MAY'
        }
      ].freeze

      SEARCH_PARAM_METADATA = {
        'AdverseEvent' => [
          {
            code: 'recordedDate',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'Condition' => [
          {
            code: 'onset-date',
            type: 'date',
            expression: 'Condition.onset.as(dateTime)|Condition.onset.as(Period)',
            comparator: DEFAULT_COMPARATORS
          },
          {
            code: 'abatement-date',
            type: 'date',
            expression: 'Condition.abatement.as(dateTime)|Condition.abatement.as(Period)',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'DiagnosticReport' => [
          {
            code: 'date',
            type: 'date',
            expression: 'DiagnosticReport.effective',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'DeviceRequest' => [
          {
            code: 'do-not-perform',
            type: 'token',
            expression: "DeviceRequest.modifierExtension.where(url='http://hl7.org/fhir/5.0/StructureDefinition/extension-DeviceRequest.doNotPerform').value.as(boolean)"
          }
        ],
        'Encounter' => [
          {
            code: 'date',
            expression: 'Encounter.period',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'Immunization' => [
          {
            code: 'date',
            type: 'date',
            expression: 'Immunization.occurrence',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'MedicationAdministration' => [
          {
            code: 'effective-time',
            type: 'date',
            expression: 'MedicationAdministration.effective',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'DeviceRequest' => [
          {
            code: 'do-not-perform',
            type: 'token',
            expression: "DeviceRequest.extension.where(url = 	'http://hl7.org/fhir/5.0/StructureDefinition/extension-DeviceRequest.doNotPerform').value"
          }
        ],
        'MedicationRequest' => [
          {
            code: 'intent'
          },
          {
            code: 'do-not-perform',
            type: 'token',
            expression: 'MedicationRequest.doNotPerform'
          }
        ],
        'Observation' => [
          {
            code: 'date',
            type: 'date',
            expression: 'Observation.effective',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'Procedure' => [
          {
            code: 'date',
            type: 'date',
            expression: 'Procedure.performed',
            comparator: DEFAULT_COMPARATORS
          }
        ],
        'ServiceRequest' => [
          {
            code: 'authored',
            expression: 'ServiceRequest.authoredOn',
            comparator: DEFAULT_COMPARATORS
          },
          {
            code: 'do-not-perform',
            type: 'token',
            expression: 'ServiceRequest.doNotPerform'
          }
        ],
        'Task' => [
          {
            code: 'patient',
            type: 'reference',
            expression: 'Task.for.where(resolve() is Patient)'
          }
        ]
      }.freeze

      def self.search_parameter_metadata(resource_type)
        SEARCH_PARAM_METADATA[resource_type] || []
      end

      def self.search_parameter_type(resource_type, metadata)
        return metadata[:type] if metadata[:type]

        expression = metadata[:expression]
        path = nil

        if expression.present?
          # Resolve the where and resolve methods in expression
          path = expression.gsub(/.where\(resolve\((.*)/, '').gsub('url = \'', 'url=\'')
          path = path[1..-2] if path.start_with?('(') && path.end_with?(')')
          path.scan(/[. ]as[( ]([^)]*)[)]?/).flatten.map do |as_type|
            path.gsub!(/[. ]as[( ](#{as_type}[^)]*)[)]?/, as_type.upcase_first) if as_type.present?
          end

          # If the target element has choice types, we cannot assume search type from the element
          full_paths = path.split('|')
          return '' if full_paths.count > 1

          # Remove the leading resource type
          path = path.split('.', 2)[1]
        else
          path = metadata[:code]
        end

        element = FHIR.const_get(resource_type)::METADATA[path]

        return '' unless element.present?

        case element['type']
        when 'date', 'dateTime', 'instant', 'Period'
          'date'
        when 'code', 'Coding', 'CodeableConcept', 'Identifier'
          'token'
        end
      end

      SEARCH_PARAM_COMBINATION = {
        'Condition' => [
          {
            code: %w[patient abatement-date],
            expectation: 'SHOULD'
          },
          {
            code: %w[patient category],
            expectation: 'SHALL'
          },
          {
            code: %w[patient code],
            expectation: 'SHOULD'
          },
          {
            code: %w[patient onset-date],
            expectation: 'SHOULD'
          }
        ],
        'DeviceRequest' => [
          {
            code: %w[patient code],
            expectation: 'SHALL'
          },
          {
            code: %w[patient do-not-perform],
            expectation: 'SHALL'
          }
        ],
        'DiagnosticReport' => [
          {
            code: %w[patient category],
            expectation: 'SHALL'
          },
          {
            code: %w[patient category date],
            expectation: 'SHALL'
          },
          {
            code: %w[patient code],
            expectation: 'SHALL'
          }
        ],
        'Immunization' => [
          {
            code: %w[patient date],
            expectation: 'SHOULD'
          },
          {
            code: %w[patient status],
            expectation: 'SHALL'
          }
        ],
        'MedicationRequest' => [
          {
            code: %w[patient intent],
            expectation: 'SHALL'
          },
          {
            code: %w[patient do-not-perform],
            expectation: 'SHALL'
          }
        ],
        'Observation' => [
          {
            code: %w[patient category],
            expectation: 'SHALL'
          },
          {
            code: %w[patient category date],
            expectation: 'SHALL'
          },
          {
            code: %w[patient code],
            expectation: 'SHALL'
          },
          {
            code: %w[patient status],
            expectation: 'SHALL'
          }
        ],
        'ServiceRequest' => [
          {
            code: %w[patient category],
            expectation: 'SHALL'
          },
          {
            code: %w[patient category authored],
            expectation: 'SHALL'
          },
          {
            code: %w[patient code],
            expectation: 'SHALL'
          },
          {
            code: %w[patient do-not-perform],
            expectation: 'SHALL'
          }
        ]
      }.freeze

      def self.search_parameter_combination(resource_type)
        SEARCH_PARAM_COMBINATION[resource_type] || []
      end
    end
  end
end
