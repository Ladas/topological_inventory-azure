require "topological_inventory/azure/logging"
require "topological_inventory/providers/common/operations/source"
require "topological_inventory/azure/connection"

module TopologicalInventory
  module Azure
    module Operations
      class Source < TopologicalInventory::Providers::Common::Operations::Source
        include Logging

        private

        def connection_check(source_id)
          TopologicalInventory::Azure::Connection.all_subscriptions(
            :client_id     => authentication.username,
            :client_secret => authentication.password,
            :tenant_id     => authentication.extra&.dig("azure", "tenant_id")
          )

          [STATUS_AVAILABLE, nil]
        rescue => e
          logger.availability_check("Failed to connect to Source id:#{source_id} - #{e.message}", :error)
          [STATUS_UNAVAILABLE, e.message]
        end

        def authentication
          @authentication ||= api_client.fetch_authentication(source_id, endpoint, 'tenant_id_client_id_client_secret')
        end
      end
    end
  end
end
