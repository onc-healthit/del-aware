# frozen_string_literal: true

module Delaware
  class ConfigLoadError < Error; end
  class ConfigParseError < Error; end
  class ConfigInvalidError < Error; end
  class ConfigUninitializedError < Error; end

  # Represents a configuration for del-aware processing.
  class Config
    include Log

    ATTRIBUTES = %i[
      name
      ig_id
      base_url
      fhir_version
      us_core_version
      tag
      tag_id
      version
      date
      cqf_tooling_binary
      stu_version
      content
    ].freeze

    attr_reader(*ATTRIBUTES)

    def initialize(values = {})
      log_debug 'Initializing configuration'

      values.symbolize_keys!

      ATTRIBUTES.each do |attr|
        value = values[attr]
        raise ConfigInvalidError, "Config must contain a non-blank `#{attr}`" if value.blank?

        instance_variable_set(:"@#{attr}", value)
      end

      freeze
    end

    class << self
      def current
        @current || raise(ConfigUninitializedError, 'Config has not been initialized')
      end

      def from_file(filepath)
        log_info "Loading config from #{filepath}"

        raise ConfigLoadError, "Config file does not exist: #{filepath}" unless File.file?(filepath)

        values = begin
          YAML.safe_load_file(filepath, permitted_classes: [Date])
        rescue StandardError => e
          raise ConfigParseError, "Failed to parse config: #{e}"
        end

        raise ConfigParseError, 'Config is not valid' unless values.is_a?(Hash)

        @current = new(values)
      end

      ATTRIBUTES.each do |attr|
        define_method(attr) { current.public_send(attr) }
      end
    end
  end
end
