#!/usr/bin/env ruby

# frozen_string_literal: true

#
# Script to convert DEL spreadsheet to JSON for use by DEL-AWARE.
#
# Usage:
#
# ```sh
# ruby del2json.rb <path to xlsx> <path to output>
# ```
#
# Example (from repository root):
#
# ```sh
# ruby scripts/del2json.rb ~/Desktop/del_2025_12_02.xlsx example/del_2025_12_02.json
# ```
#

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'byebug'
  gem 'activesupport', '~> 8.0'
  gem 'csv'
  gem 'roo'
end

require 'json'
require 'active_support/all'
require 'csv'
require 'roo'

################################################################################
# Helpers
################################################################################

def as_array(text)
  return [] unless text

  text.delete('"')
      .split(/[,\s]+/)
      .map(&:strip)
      .reject(&:empty?)
      .uniq
end

def clean_text(text)
  return '' unless text

  text.tr("\u2013\u2019\n", "-' ").tr("\u00a0", '').strip
end

def clean_resource_url(url)
  url.strip!
  url.gsub!('https://www.hl7.org', 'http://hl7.org')
  url.gsub!('StructureDefinition-', 'StructureDefinition/')
  url.gsub!(%r{STU.*/StructureDefinition}, 'StructureDefinition')
  url.gsub!('fhir', 'fhir/StructureDefinition') unless url.include?('StructureDefinition')
  url.gsub!('.html', '')
  url.gsub!('%C3%A5%C3%9F', '')
  url
end

################################################################################
# Main
################################################################################

xlsx = Roo::Spreadsheet.open(ARGV[0], extension: :xlsx)
sheet = xlsx.sheet('uscdiplusqualityDEL_v1')

data = []
sheet.each(
  data_class: 'Data Class',
  data_element_name: 'Data Element Name',
  description: 'Description',
  elements: 'FHIR Resource Elements',
  current_qi_core_urls: /QI-Core v6.0.0 Profile URLs.*/,
  current_us_core_urls: /US Core v6.1.0 Profile URLs.*/,
  future_qi_core_urls: /Future versions of QI-Core Profile URLs.*/,
  future_us_core_urls: /Future versions of US Core Profile URLs.*/,
  bucket: 'Implementation Phase / Mapping Bucket'
) do |hash|
  mapped_elements = as_array(hash[:elements])
  mapped_current_qi_core_profiles = as_array(hash[:current_qi_core_urls]).map { |url| clean_resource_url(url) }

  # TODO: This will no longer be necessary when spreadsheet URLs are pointing to the new IG
  mapped_current_qi_core_profiles = mapped_current_qi_core_profiles.map do |url|
    url.gsub('us/qicore', 'us/quality-core').gsub('qicore', 'us-quality-core')
  end

  mapped_current_us_core_profiles = as_array(hash[:current_us_core_urls]) # Don't strip out versions
  mapped_future_qi_core_profiles = as_array(hash[:future_qi_core_urls]) # Don't strip out versions
  mapped_future_us_core_profiles = as_array(hash[:future_us_core_urls]) # Don't strip out versions

  data << {
    class: clean_text(hash[:data_class]),
    name: clean_text(hash[:data_element_name]),
    description: clean_text(hash[:description]),
    bucket: clean_text(hash[:bucket].to_s).to_i,
    mappings: {
      elements: mapped_elements.uniq,
      current: {
        qi_core_profiles: mapped_current_qi_core_profiles.uniq,
        us_core_profiles: mapped_current_us_core_profiles.uniq
      },
      future: {
        qi_core_profiles: mapped_future_qi_core_profiles.uniq,
        us_core_profiles: mapped_future_us_core_profiles.uniq
      }
    }
  }
end
data = data.drop(1) # Skip headers

output_json = JSON.pretty_generate(JSON.parse(data.to_json))
output_filepath = ARGV[1]
File.write(output_filepath, output_json)
puts "Wrote JSON to #{output_filepath}"
