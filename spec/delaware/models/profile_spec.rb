# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Models::Profile do
  describe '#initialize' do
    it 'without error' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '#elements' do
    let(:profile) { build(:profile) }
    let(:profile_with_snapshot) { build(:profile, :with_snapshot) }

    it 'uses snapshot by default' do
      expect(profile_with_snapshot.elements.count).to eq(4)
    end

    it 'falls back to differential when no snapshot' do
      expect(profile.elements.count).to eq(2)
    end
  end

  describe '#tagged_elements' do
    let(:config) { Delaware::Config.from_file('example/config.yaml') }
    let(:profile) { build(:profile) }

    it 'returns an empty array when no matches' do
      expect(profile.tagged_elements('bogus').count).to eq(0)
    end
  end
end
