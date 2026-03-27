# frozen_string_literal: true

# Creates a tag Extension for an element definition
FactoryBot.define do
  factory :tag_extension, class: FHIR::R4::Extension do
    config { build(:config) }

    transient do
      base_url { config.base_url }
      tag_id { config.tag_id }
    end

    url { "#{base_url}/StructureDefinition/#{tag_id}" }
    valueBoolean { true }

    initialize_with { new(**attributes) }
  end
end
