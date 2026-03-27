# frozen_string_literal: true

FactoryBot.define do
  # Creates a Requirement for a Data Element.
  # An index can be provided for Data Elements that have multiple Data Requirements
  factory :data_requirement, class: Delaware::Models::DataRequirement do
    transient do
      profile_base { 'Profile' }
      index { 1 }
    end

    id { |_n| "#{profile_base}.element#{index}" }
    resource { id.split('.').first }
    ig_profile_id { resource.downcase }

    initialize_with { new(**attributes) }
  end
end
