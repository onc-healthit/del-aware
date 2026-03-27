# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Models::DataRequirement do
  describe '#initialize' do
    it 'without error' do
      expect { described_class.new }.not_to raise_error
    end
  end
end
