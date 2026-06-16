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

      def self.capability_statement_resource_documentation(mode, resource_type)
        path = capability_statement_resource_documentation_path(mode, resource_type)

        return nil unless File.file?(path)

        log_info "Loading #{mode} capability statement #{resource_type} resource documentation content from #{path}"

        File.read(path).chomp
      end

      def self.capability_statement_resource_documentation_path(mode, resource_type)
        paths = [
          File.join(Config.content, "#{mode}_capability_statement_resource_documentation", "#{resource_type}.md"),
          File.join(Config.content, 'capability_statement_resource_documentation', "#{resource_type}.md")
        ]
        paths << File.join(Config.content, 'server_capability_statement_resource_documentation', "#{resource_type}.md") if mode == 'client'

        paths.find { |path| File.file?(path) } || paths.first
      end
    end
  end
end
