# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Delaware::Models::ImplementationGuide do
  describe '#initialize' do
    it 'without error' do
      expect { described_class.new }.not_to raise_error
    end
  end

  describe '#apply_del_tags' do
    it 'Annotation added for 1 element' do
      config = build(:config)
      ig = build(:implementation_guide, config: config)
      original_annotation_count = ig.profiles['Profile'].differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } || e.short&.include?(config.tag)
      end
      expect(original_annotation_count).to eq(0)
      ig.apply_del_tags(build(:data_element_list))
      final_annotation_count = ig.profiles['Profile'].differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } && e.short&.include?(config.tag)
      end
      expect(final_annotation_count).to eq(1)
    end

    it 'Annotation added for 2 elements' do
      config = build(:config)
      ig = build(:implementation_guide)
      original_annotation_count = ig.profiles['Profile'].differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } || e.short&.include?(config.tag)
      end
      expect(original_annotation_count).to eq(0)
      data_element = build(:data_element, data_requirement_count: 2)
      ig.apply_del_tags(build(:data_element_list, data_elements: [data_element]))
      final_annotation_count = ig.profiles['Profile'].differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } && e.short&.include?(config.tag)
      end
      expect(final_annotation_count).to eq(2)
    end

    it 'Annotation removed for missing elements' do
      config = build(:config)
      element_definition = build(:element_definition, profile: 'Profile', element_name: 'SomeElement', tag: config.tag, tag_id: config.tag_id)
      profile = build(:profile, name: 'Profile', differential: { element: [element_definition] })
      ig = build(:implementation_guide, profile_list: [profile], config: config)
      original_differential = ig.profiles['Profile'].differential
      original_element_count = original_differential.element.count { |e| e.id.include? 'SomeElement' }
      original_annotation_count = original_differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } || e.short&.include?(config.tag)
      end
      expect(original_element_count).to eq(1)
      expect(original_annotation_count).to eq(1)
      ig.apply_del_tags(build(:data_element_list, data_element_count: 0))
      final_differential = ig.profiles['Profile'].differential
      final_element_count = final_differential.element.count { |e| e.id.include? 'SomeElement' }
      final_annotation_count = final_differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } || e.short&.include?(config.tag)
      end
      expect(final_element_count).to eq(1)
      expect(final_annotation_count).to eq(0)
    end

    it 'Annotation not added for elements in wrong profile' do
      config = build(:config)
      ig = build(:implementation_guide)
      original_annotation_count = ig.profiles['Profile'].differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } || e.short&.include?(config.tag)
      end
      expect(original_annotation_count).to eq(0)
      data_element = build(:data_element, data_requirement_count: 2, profile_base: 'OtherProfile')
      ig.apply_del_tags(build(:data_element_list, data_elements: [data_element]))
      final_annotation_count = ig.profiles['Profile'].differential.element.count do |e|
        e.extension.any? { |extension| extension.url&.include? config.tag_id } || e.short&.include?(config.tag)
      end
      expect(final_annotation_count).to eq(0)
    end
  end
end
