# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Models::DataElement do
  describe '#initialize' do
    it 'without error' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '.from_json' do
    let(:config) { Delaware::Config.from_file('example/config.yaml') }
    let(:json) do
      JSON.parse(
        JSON.generate(
          {
            class: 'Laboratory',
            name: 'Tests',
            mappings: {
              current: {
                qi_core_profiles: [
                  'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-simple-observation',
                  'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-diagnosticreport-lab',
                  'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-observation-lab'
                ]
              },
              future: {
                qi_core_profiles: [],
                elements: []
              },
              elements: [
                'Observation.category',
                'Observation.category:us-core',
                'Observation.code',
                'DiagnosticReport.category',
                'DiagnosticReport.category:LaboratorySlice',
                'DiagnosticReport.code'
              ]
            }
          }
        )
      )
    end
    let(:profiles) do
      # rubocop:disable all
      {'SimpleObservation':
        FHIR::R4::StructureDefinition::new({
          url: 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-simple-observation',
          type: 'Observation',
          id: 'qicore-simple-observation',
          differential: FHIR::R4::StructureDefinition::Differential.new({
            element: [
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.category'
              }),
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.category:us-core'
              }),
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.code'
              }),
            ]
          })
        }),
        'DiagnosticReportNote': FHIR::R4::StructureDefinition::new({
          url: 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-diagnosticreport-lab',
          type: 'DiagnosticReport',
          id: 'qicore-diagnosticreport-lab',
          differential: FHIR::R4::StructureDefinition::Differential.new({
            element: [
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.category'
              }),
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.category:us-core'
              }),
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.code'
              }),
            ]
          })
        }),
        'LaboratoryResultObservation': FHIR::R4::StructureDefinition::new({
          url: 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-observation-lab',
          type: 'Observation',
          id: 'qicore-observation-lab',
          differential: FHIR::R4::StructureDefinition::Differential.new({
            element: [
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.category'
              }),
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.category:us-core'
              }),
              FHIR::R4::ElementDefinition.new({
                id: 'Observation.code'
              }),
            ]
          })
        })
      }
      # rubocop:enable all
    end

    it 'parses data element' do
      data_element = described_class.from_json(json, profiles)

      expect(data_element.klass).to eq('Laboratory')
      expect(data_element.name).to eq('Tests')
      expect(data_element.data_requirements.length).to eq(9)
      data_requirement = data_element.data_requirements.find { |dr| dr.id == 'Observation.category' }
      expect(data_requirement).to have_attributes(
        id: 'Observation.category',
        resource: 'Observation',
        ig_profile_id: 'qicore-simple-observation'
      )
    end
  end

  describe '.to_json' do
    let(:config) { Delaware::Config.from_file('example/config.yaml') }
    let(:data_element) { build(:data_element, data_requirement_count: 2) }

    it 'exports data element to JSON' do
      json = data_element.to_json(config)

      expect(json[:class]).to eq(data_element.klass)
      expect(json[:name]).to eq(data_element.name)
      expect(json[:mappings]).to eq(
        {
          profiles: data_element.data_requirements.map { |requirement| "#{config.base_url}/StructureDefinition/#{requirement.ig_profile_id}" }.uniq,
          elements: data_element.data_requirements.map(&:id)
        }
      )
    end
  end
end
