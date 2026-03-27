# frozen_string_literal: true

module Delaware
  module Helpers
    # Helper module for loading and processing files
    module FileLoader
      include Log
      include PathHelper

      def self.load_profiles(directory_path)
        log_info "Loading profiles from #{directory_path}"

        profiles = {}
        Dir.glob(File.join(directory_path, '**', 'input', 'profiles', '*.json')).each do |file_path|
          json = File.read(file_path)
          profile = Models::Profile.from_json(json)
          key = profile.name.gsub(Config.name.gsub(/\s+/, ''), '')
          profiles[key] = profile
        end
        profiles
      end

      def self.save_profiles(destination, profiles)
        log_info "Saving IG source to #{destination}"

        profiles.each_value do |profile|
          profile_path = File.join(destination, 'input', 'profiles', "StructureDefinition-#{profile.id}.json")
          log_info "Profile path is: #{profile_path}"
          FileUtils.mkdir_p(File.dirname(profile_path))
          File.write(profile_path, profile.to_json)
        end
      end
    end
  end
end
