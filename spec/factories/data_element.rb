# frozen_string_literal: true

FactoryBot.define do
  # Creates a unique Data Element with 1 or more Data Requirements from the same profile
  factory :data_element, class: Delaware::Models::DataElement do
    sequence(:klass) { |n| "DataElementClass#{n}" }
    sequence(:name) { |n| "DataElement#{n}" }

    transient do
      data_requirement_count { 1 }
      profile_base { 'Profile' }
    end

    after(:build) do |data_element, evaluator|
      evaluator.data_requirement_count.times do |count|
        data_element.data_requirements << build(:data_requirement, index: count, profile_base: evaluator.profile_base)
      end
    end

    initialize_with { new(**attributes) }
  end
end
