# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Config do
  describe '#initialize' do
    context 'with a title that is is nil' do
      it 'a ConfigInvalidError is raised' do
        expect { described_class.new({ title: nil }) }.to raise_error(Delaware::ConfigInvalidError)
      end
    end

    context 'with a title that is is blank' do
      it 'a ConfigInvalidError is raised' do
        expect { described_class.new({ title: ' ' }) }.to raise_error(Delaware::ConfigInvalidError)
      end
    end

    context 'with a title that is is undefined' do
      it 'a ConfigInvalidError is raised' do
        expect { described_class.new({}) }.to raise_error(Delaware::ConfigInvalidError)
      end
    end
  end

  describe '.from_file' do
    context 'when filepath points to something that does not exist' do
      it 'a ConfigLoadError is raised' do
        expect { described_class.from_file('foo') }.to raise_error(Delaware::ConfigLoadError)
      end
    end

    context 'when filepath points to something that is not valid YAML' do
      it 'a ConfigParseError is raised' do
        invalid_yaml = temp_file('foo', ':')
        expect { described_class.from_file(invalid_yaml.path) }.to raise_error(Delaware::ConfigParseError)
      end
    end

    context 'when filepath points to something that does not contain key/values' do
      it 'a ConfigParseError is raised' do
        invalid_type = temp_file('foo', 'bar')
        expect { described_class.from_file(invalid_type.path) }.to raise_error(Delaware::ConfigParseError)
      end
    end
  end
end
