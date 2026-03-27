# frozen_string_literal: true

module Delaware
  module Helpers
    # Helper module for loading custom content
    module ContentLoader
      include Log

      def self.server_capability_statement_description
        path = File.join(Config.content, 'server_capability_statement_description.md')

        log_info "Loading server capability statement description content from #{path}"

        File.read(path)
      end

      def self.server_capability_statement_rest_documentation
        path = File.join(Config.content, 'server_capability_statement_rest_documentation.md')

        log_info "Loading server capability statement REST documentation content from #{path}"

        File.read(path)
      end

      def self.client_capability_statement_description
        path = File.join(Config.content, 'client_capability_statement_description.md')

        log_info "Loading client capability statement description content from #{path}"

        File.read(path)
      end

      def self.client_capability_statement_rest_documentation
        path = File.join(Config.content, 'client_capability_statement_rest_documentation.md')

        log_info "Loading client capability statement REST documentation content from #{path}"

        File.read(path)
      end
    end
  end
end
