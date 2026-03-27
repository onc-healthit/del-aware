# frozen_string_literal: true

FactoryBot.define do
  # Creates a configuration
  factory :config, class: Delaware::Config do
    name { 'QI-Core' }
    ig_id { 'qicore' }
    date { Date.today }
    base_url { 'http://hl7.org/fhir/us/qicore-uscdiplus-quality' }
    version { '0.0.0' }
    fhir_version { '4.0.1' }
    us_core_version { '6.1.0' }
    tag_id { 'uscdiplusquality' }
    tag { 'USCDI+ Quality' }
    stu_version { 6 }
    cqf_tooling_binary { 'https://search.maven.org/remotecontent?filepath=org/opencds/cqf/tooling-cli/3.6.0/tooling-cli-3.6.0.jar' }
    initialize_with { new(**attributes) }
    content { 'example/content' }
  end
end
