# frozen_string_literal: true

module Delaware
  class CqfToolingError < Error; end

  module Services
    # Wrapper for utilizing cqf-tooling functionality
    class CqfTooling
      include Log

      def initialize
        log_debug 'Initializing CqfTooling service'

        download_jar(Config.cqf_tooling_binary)

        @base_command = 'java -jar ./cache/cqf-tooling.jar'
      end

      def generate_modelinfo(output_path, input_path, resource_paths)
        log_info 'Executing CqfTooling to generate a modelinfo file'

        # Define arguments dynamically based on input path and resource paths
        model_name = 'QICore'
        model_version = '6.0.0'

        # Construct the command
        command = "#{@base_command} -GenerateMIs -inputPath=#{input_path} -resourcePaths=#{resource_paths} \
        -modelName=#{model_name} -modelVersion=#{model_version} -outputPath=#{output_path}"

        begin
          log_info "Executing: #{command}"

          # Run the command and capture output
          stdout, stderr, status = Open3.capture3(command)

          unless status.success?
            raise CqfToolingError,
                  "Command failed with status #{status.exitstatus}. Error:\n#{stderr}"
          end

          log_info 'Command executed successfully!'
          log_info "Output:\n#{stdout}"
          log_info "Generated modelinfo file at: #{output_path}"
        rescue Errno::ENOENT
          raise CqfToolingError, '`java` command not found. Make sure Java is installed and accessible in your PATH.'
        rescue StandardError => e
          raise CqfToolingError, "An unexpected error occurred: #{e.message}"
        end
      end

      private

      def download_jar(maven_source)
        raise CqfToolingError, 'Must provide valid source for cqf-tooling binary' if maven_source.blank?

        log_info 'Checking for cqf-tooling.jar'

        target = './cache/cqf-tooling.jar'

        return if File.file?(target)

        log_info 'Downloading cqf-tooling.jar'

        retries = 3
        begin
          File.open(target, 'wb') do |file|
            file.write RestClient::Request.execute(
              method: :get,
              url: maven_source,
              timeout: 30, # Set timeout to 30 seconds
              open_timeout: 30 # Set open timeout to 30 seconds
            )
            file.rewind
            file
          end
        rescue RestClient::Exceptions::ReadTimeout, RestClient::Exceptions::OpenTimeout => e
          retries -= 1
          raise CqfToolingError, "Failed to download cqf-tooling.jar after multiple attempts: #{e.message}" unless retries.positive?

          log_warn "Timeout encountered while downloading cqf-tooling.jar. Retrying... (#{retries} retries left)"
          retry
        rescue StandardError => e
          raise CqfToolingError, "An unexpected error occurred while downloading cqf-tooling.jar: #{e.message}"
        end
      end
    end
  end
end
