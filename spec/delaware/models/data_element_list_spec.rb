# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Models::DataElementList do
  describe '#initialize' do
    it 'without error' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '.from_json' do
    let(:config) { Delaware::Config.from_file('example/config.yaml') }
    let(:json) do
      JSON.generate(
        [
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
        ]
      )
    end
    let(:profiles) do
      { SimpleObservation:
        FHIR::R4::StructureDefinition.new({
                                            url: 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-simple-observation'
                                          }),
        DiagnosticReportNote: FHIR::R4::StructureDefinition.new({
                                                                  url: 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-diagnosticreport-lab'
                                                                }),
        LaboratoryResultObservation: FHIR::R4::StructureDefinition.new({
                                                                         url: 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition/qicore-observation-lab'
                                                                       }) }
    end

    it 'parses DEL JSON string' do
      data_element_list = described_class.from_json(json, profiles)
      expect(data_element_list.name).to eq('Data Element List')
      expect(data_element_list.data_elements.length).to eq(1)
    end
  end

  describe '.to_json' do
    let(:data_element_list) { build(:data_element_list, data_element_count: 2) }

    it 'exports DEL to JSON' do
      Delaware::Config.from_file('example/config.yaml')
      json = JSON.parse(data_element_list.to_json)
      expect(json.length).to eq(data_element_list.data_elements.length)
      expect(json.first['class']).to eq(data_element_list.data_elements.first.klass)
      expect(json.first['name']).to eq(data_element_list.data_elements.first.name)
      expect(json.last['class']).to eq(data_element_list.data_elements.last.klass)
      expect(json.last['name']).to eq(data_element_list.data_elements.last.name)
    end
  end
end
