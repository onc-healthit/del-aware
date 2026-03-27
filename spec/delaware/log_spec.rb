# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Log do
  let(:test_obj) { Object.new.extend(described_class) }

  it 'logs debug message' do
    expect { test_obj.log_debug('foo') }.to output(/foo/).to_stdout
  end

  it 'logs info message' do
    expect { test_obj.log_info('foo') }.to output(/foo/).to_stdout
  end

  it 'logs warn message' do
    expect { test_obj.log_warn('foo') }.to output(/foo/).to_stdout
  end

  it 'logs error message' do
    expect { test_obj.log_error('foo') }.to output(/foo/).to_stderr
  end
end
