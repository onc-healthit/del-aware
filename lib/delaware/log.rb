# frozen_string_literal: true

module Delaware
  # Helpful methods for logging information.
  module Log
    def log_debug(message)
      to_stdout.debug(prefix(message))
    end

    def log_info(message)
      to_stdout.info(prefix(message))
    end

    def log_warn(message)
      to_stdout.warn(Rainbow(prefix(message)).yellow)
    end

    def log_error(message)
      to_stderr.error(Rainbow(prefix(message)).red)
    end

    def self.included(base)
      base.extend(self)
    end

    private

    def prefix(message)
      from = is_a?(Class) || is_a?(Module) ? self : self.class
      "[#{from}] #{message}"
    end

    def to_stdout
      @to_stdout ||= Logger.new($stdout)
    end

    def to_stderr
      @to_stderr ||= Logger.new($stderr)
    end
  end
end
