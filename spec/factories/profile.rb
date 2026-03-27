# frozen_string_literal: true

FactoryBot.define do
  # Create a Profile with an array of Elements
  factory :profile, class: Delaware::Models::Profile do
    name { 'Profile' }
    id { "qicore-#{name}" }
    differential { { 'element' => {} } }

    transient do
      differential_element_count { 2 }
      snapshot_element_count { 4 }
    end

    trait :with_snapshot do
      snapshot { { 'element' => {} } }
    end

    after(:build) do |profile, evaluator|
      evaluator.differential_element_count.times do |count|
        profile.differential.element << build(:element_definition, profile: profile.name, element_name: "element#{count}")
      end

      unless profile.snapshot.nil?
        evaluator.snapshot_element_count.times do |count|
          profile.snapshot.element << build(:element_definition, profile: profile.name, element_name: "element#{count}")
        end
      end
    end

    initialize_with { new(**attributes) }
  end
end
