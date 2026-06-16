# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Delaware::Generators::CapabilityStatementServer do
  around do |example|
    previous_config = Delaware::Config.instance_variable_get(:@current)
    Delaware::Config.instance_variable_set(:@current, config)

    example.run
  ensure
    Delaware::Config.instance_variable_set(:@current, previous_config)
  end

  let(:config) { build(:config, content: content_dir) }
  let(:content_dir) { Dir.mktmpdir }
  let(:generator) { described_class.new({}, data_element_list, content_dir) }

  before do
    File.write(File.join(content_dir, 'server_capability_statement_description.md'), "Description.\n")
    File.write(File.join(content_dir, 'server_capability_statement_rest_documentation.md'), "REST documentation.\n")
    File.write(File.join(content_dir, 'client_capability_statement_description.md'), "Client description.\n")
    File.write(File.join(content_dir, 'client_capability_statement_rest_documentation.md'), "Client REST documentation.\n")
  end

  after do
    FileUtils.remove_entry(content_dir)
  end

  describe '#capability_statement_hash' do
    context 'when server resource documentation content exists' do
      let(:data_element_list) { data_element_list_for('Patient') }

      before do
        documentation_dir = File.join(content_dir, 'server_capability_statement_resource_documentation')
        FileUtils.mkdir_p(documentation_dir)
        File.write(File.join(documentation_dir, 'Patient.md'), "Resource narrative.\n")
      end

      it 'includes the resource documentation without the content file trailing newline' do
        patient_resource = resource_for(generator, 'Patient')

        expect(patient_resource['documentation']).to eq('Resource narrative.')
      end
    end

    context 'when no matching resource documentation content exists' do
      let(:data_element_list) { data_element_list_for('Practitioner') }

      it 'omits resource documentation' do
        practitioner_resource = resource_for(generator, 'Practitioner')

        expect(practitioner_resource).not_to have_key('documentation')
      end
    end

    context 'when a client-specific resource documentation file does not exist' do
      let(:data_element_list) { data_element_list_for('Patient') }

      before do
        documentation_dir = File.join(content_dir, 'server_capability_statement_resource_documentation')
        FileUtils.mkdir_p(documentation_dir)
        File.write(File.join(documentation_dir, 'Patient.md'), "Shared resource narrative.\n")
      end

      it 'uses the server resource documentation for the client capability statement' do
        client_generator = Delaware::Generators::CapabilityStatementClient.new({}, data_element_list, content_dir)
        patient_resource = resource_for(client_generator, 'Patient')

        expect(patient_resource['documentation']).to eq('Shared resource narrative.')
      end
    end

    context 'when US Core search parameter definitions are generated from metadata' do
      let(:data_element_list) { data_element_list_for('DocumentReference') }

      it 'pins US Core definitions to the configured US Core version' do
        document_reference_resource = resource_for(generator, 'DocumentReference')
        definitions = document_reference_resource['searchParam'].to_h { |param| [param['name'], param['definition']] }

        expect(definitions).to include(
          'patient' => 'http://hl7.org/fhir/us/core/SearchParameter/us-core-documentreference-patient|6.1.0',
          '_id' => 'http://hl7.org/fhir/us/core/SearchParameter/us-core-documentreference-id|6.1.0',
          'category' => 'http://hl7.org/fhir/us/core/SearchParameter/us-core-documentreference-category|6.1.0',
          'date' => 'http://hl7.org/fhir/us/core/SearchParameter/us-core-documentreference-date|6.1.0',
          'type' => 'http://hl7.org/fhir/us/core/SearchParameter/us-core-documentreference-type|6.1.0'
        )
      end
    end

    context 'when a resource should only declare read interaction support' do
      let(:data_element_list) { data_element_list_for('Location') }

      it 'does not add a search-type interaction' do
        location_resource = resource_for(generator, 'Location')

        expect(location_resource['interaction'].map { |interaction| interaction['code'] }).to eq(['read'])
      end
    end
  end

  describe '#generate' do
    let(:data_element_list) { data_element_list_for('Patient') }
    let(:generator) { described_class.new(profiles, data_element_list, content_dir) }
    let(:profiles) do
      {
        'patient' => profile_for('Patient'),
        'imagingstudy' => profile_for('ImagingStudy')
      }
    end

    it 'generates supporting SearchParameters only for supported profiles' do
      generator.generate

      expect(File).to exist(File.join(content_dir, 'SearchParameter-qicore-patient-id.json'))
      expect(File).not_to exist(File.join(content_dir, 'SearchParameter-qicore-imagingstudy-patient.json'))
    end
  end

  def resource_for(generator, type)
    generator.capability_statement_hash.dig('rest', 0, 'resource').find { |resource| resource['type'] == type }
  end

  def profile_for(resource)
    id = resource.underscore.dasherize
    build(
      :profile,
      id: id,
      type: resource,
      url: "#{config.base_url}/StructureDefinition/#{id}"
    )
  end

  def data_element_list_for(resource)
    data_requirement = Delaware::Models::DataRequirement.new(
      id: "#{resource}.id",
      resource: resource,
      ig_profile_id: resource.underscore.dasherize
    )
    data_element = Delaware::Models::DataElement.new(
      klass: 'Class',
      name: resource,
      data_requirements: [data_requirement]
    )

    Delaware::Models::DataElementList.new(data_elements: [data_element])
  end
end
