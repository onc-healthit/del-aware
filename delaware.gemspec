# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'delaware/version'

Gem::Specification.new do |spec|
  spec.name          = 'delaware'
  spec.version       = Delaware::VERSION
  spec.authors       = ['MITRE']
  spec.summary       = 'delaware'
  spec.description   = 'DEL-AWARE'

  spec.add_dependency 'fhir_models', '~> 5.0'
  spec.add_dependency 'logger', '~> 1.6'
  spec.add_dependency 'open3', '~> 0.2.1'
  spec.add_dependency 'rainbow', '~> 3.1'
  spec.add_dependency 'rest-client', '~> 2.1'
  spec.add_dependency 'thor', '~> 1.4.0'
  spec.add_dependency 'time', '~> 0.4'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.require_paths = ['lib']
  spec.executables   = ['delaware']
end
