require "topological_inventory/azure/logging"
require "topological_inventory/azure/messaging_client"
require "topological_inventory/azure/operations/processor"
require "topological_inventory/azure/operations/source"
require "topological_inventory/providers/common/mixins/statuses"
require "topological_inventory/providers/common/operations/health_check"

module TopologicalInventory
  module Azure
    module Operations
      class Worker
        include Logging
        include TopologicalInventory::Providers::Common::Mixins::Statuses

        def initialize(metrics)
          self.metrics = metrics
        end

        def run
          logger.info("Topological Inventory Azure Operations worker started...")

          client.subscribe_topic(queue_opts) do |message|
            process_message(message)
          end
        rescue => err
          logger.error("#{err.cause}\n#{err.backtrace.join("\n")}")
        ensure
          client&.close
        end

        private

        attr_accessor :metrics

        def client
          @client ||= TopologicalInventory::Azure::MessagingClient.default.worker_listener
        end

        def queue_opts
          TopologicalInventory::Azure::MessagingClient.default.worker_listener_queue_opts
        end

        def process_message(message)
          result = Processor.process!(message, metrics)
          metrics&.record_operation(message.message, :status => result)
        rescue => e
          logger.error("#{e}\n#{e.backtrace.join("\n")}")
          metrics&.record_operation(message.message, :status => operation_status[:error])
        ensure
          message.ack
          TopologicalInventory::Providers::Common::Operations::HealthCheck.touch_file
        end
      end
    end
  end
end
