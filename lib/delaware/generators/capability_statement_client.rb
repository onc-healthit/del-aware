# frozen_string_literal: true

module Delaware
  class Generators
    # Generates a client capability statement
    class CapabilityStatementClient < CapabilityStatementServer
      def mode
        'client'
      end

      def description
        Delaware::Helpers::ContentLoader.client_capability_statement_description
      end

      def rest_documentation
        Delaware::Helpers::ContentLoader.client_capability_statement_rest_documentation
      end
    end
  end
end
