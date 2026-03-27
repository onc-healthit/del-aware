# frozen_string_literal: true

FactoryBot.define do
  # Create a Data Element List containing an array of Data Elements
  factory :data_element_list, class: Delaware::Models::DataElementList do
    name { 'Data Element List' }

    transient do
      data_element_count { 1 }
    end

    after(:build) do |data_element_list, evaluator|
      if data_element_list.data_elements.empty?
        evaluator.data_element_count.times do |_count|
          data_element_list.data_elements << build(:data_element)
        end
      end
    end

    initialize_with { new(**attributes) }
  end
end
