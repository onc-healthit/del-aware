# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Generators::MappingTable do
  describe '#in_scope_profiles and #out_of_scope_profiles' do
    let(:base_url) { 'http://hl7.org/fhir/us/qicore-uscdiplus-quality/StructureDefinition' }

    let(:profiles) do
      {
        'MedicationRequest' => build_profile('qicore-medicationrequest', 'US Quality Core MedicationRequest'),
        'AdverseEvent' => build_profile('qicore-adverseevent', 'US Quality Core AdverseEvent'),
        'ServiceRequest' => build_profile('qicore-servicerequest', 'US Quality Core ServiceRequest'),
        'Encounter' => build_profile('qicore-encounter', 'US Quality Core Encounter')
      }
    end

    let(:mappings) do
      [
        mapping_for("#{base_url}/qicore-medicationrequest"),
        mapping_for("#{base_url}/qicore-adverseevent")
      ]
    end

    let(:generator) { described_class.new(profiles, mappings, '/tmp') }

    it 'sorts in-scope profiles alphabetically by title' do
      expect(generator.in_scope_profiles.map { |profile| profile[:title] }).to eq(
        [
          'US Quality Core AdverseEvent',
          'US Quality Core MedicationRequest'
        ]
      )
    end

    it 'sorts out-of-scope profiles alphabetically by title' do
      expect(generator.out_of_scope_profiles.map { |profile| profile[:title] }).to eq(
        [
          'US Quality Core Encounter',
          'US Quality Core ServiceRequest'
        ]
      )
    end

    def build_profile(id, title)
      build(
        :profile,
        id: id,
        name: title.delete(' '),
        title: title,
        url: "#{base_url}/#{id}"
      )
    end

    def mapping_for(profile_url)
      {
        'mappings' => {
          'current' => {
            'qi_core_profiles' => [profile_url]
          }
        }
      }
    end
  end
end
