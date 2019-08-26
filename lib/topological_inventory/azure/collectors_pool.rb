require "topological_inventory-ingress_api-client/collectors_pool"
require "topological_inventory/azure/collector"
require "topological_inventory/azure/logging"

module TopologicalInventory::Azure
  class CollectorsPool < TopologicalInventoryIngressApiClient::CollectorsPool
    include Logging

    def initialize(config_name, metrics, poll_time: 10)
      super
    end

    def path_to_config
      File.expand_path("../../../config", File.dirname(__FILE__))
    end

    def path_to_secrets
      File.expand_path("../../../secret", File.dirname(__FILE__))
    end

    def new_collector(source, secret)
      TopologicalInventory::Azure::Collector.new(source.source, secret['username'], secret['password'], source.tenant_id, metrics)
    end
  end
end
