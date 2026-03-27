# frozen_string_literal: true

# Creates an element for use in a Profile
FactoryBot.define do
  factory :element_definition, class: FHIR::R4::ElementDefinition do
    extension { [] }

    transient do
      profile { 'Profile' }
      element_name { 'element1' }
      tag { nil }
      tag_id { nil }
    end

    id { "#{profile}.#{element_name}" }
    path { "#{profile}.#{element_name}" }

    initialize_with { new(**attributes) }

    after(:build) do |element_definition, evaluator|
      if evaluator.tag && evaluator.tag_id
        element_definition.short = `(#{evaluator.tag})`
        element_definition.extension << build(:tag_extension, tag_id: evaluator.tag_id)
      end
    end
  end
end
