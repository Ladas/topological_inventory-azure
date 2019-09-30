require "manageiq/loggers"

module TopologicalInventory
  module Azure
    class << self
      attr_writer :logger
    end

    def self.logger
      @logger ||= ManageIQ::Loggers::CloudWatch.new
    end

    module Logging
      def logger
        TopologicalInventory::Azure.logger
      end
    end
  end
end
