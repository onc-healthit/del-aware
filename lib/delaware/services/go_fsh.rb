# frozen_string_literal: true

module Delaware
  class GoFshError < Error; end

  module Services
    # Executes the go-fsh utility to generate FSH from an IG using a JavaScript API.
    class GoFsh
      include Log

      def initialize(input_directory = './gofsh-input', base_output_directory = './gofsh-output')
        log_debug 'Initializing GoFSH service'

        @gofsh_js_path = File.join(__dir__, 'gofsh.js') # Path to the new JavaScript file
        @input_directory = input_directory
        @base_output_directory = base_output_directory
      end

      def execute
        log_info 'Converting IG output to FSH using GoFSH API'

        # Generate a unique output directory name based on the current timestamp
        timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
        output_directory = "#{@base_output_directory}_#{timestamp}"

        # Construct the command to execute the JavaScript file
        command = "node #{@gofsh_js_path} #{@input_directory} #{output_directory}"

        begin
          log_info "Executing: #{command}"

          # Run the command and capture output
          stdout, stderr, status = Open3.capture3(command)

          raise GoFshError, "Command failed with status #{status.exitstatus}. Error:\n#{stderr}" unless status.success?

          log_info 'Command executed successfully!'
          log_info "Output:\n#{stdout}"
          log_info "Generated output directory: #{output_directory}"
          output_directory # Return the generated output directory
        rescue Errno::ENOENT
          raise GoFshError, '`node` command not found. Make sure Node.js is installed and accessible in your PATH.'
        rescue StandardError => e
          raise GoFshError, "An unexpected error occurred: #{e.message}"
        end
      end
    end
  end
end
