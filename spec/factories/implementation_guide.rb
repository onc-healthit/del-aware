# frozen_string_literal: true

FactoryBot.define do
  # Create an Implementation Guide with a default Profile or a provided array of Profiles
  factory :implementation_guide, class: Delaware::Models::ImplementationGuide do
    profiles { {} }

    config { build(:config) }

    transient do
      profile_list { [] }
    end

    initialize_with { new(**attributes) }

    after(:build) do |implementation_guide, evaluator|
      if evaluator.profile_list.empty?
        profile = build(:profile)
        key = profile.name.gsub(evaluator.config.name.gsub(/\s+/, ''), '')
        implementation_guide.profiles[key] = profile
      else
        evaluator.profile_list.each do |profile|
          key = profile.name.gsub(evaluator.config.name.gsub(/\s+/, ''), '')
          implementation_guide.profiles[key] = profile
        end
      end
    end
  end
end
