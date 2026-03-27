# frozen_string_literal: true

require 'bundler/setup'
require 'delaware'
require 'support/factory_bot'
require 'support/file_helpers'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Silence stdout logging
  config.before do
    $stdout = File.open(File::NULL, 'w')
  end
end
