require 'topological_inventory/providers/common/metrics'

module TopologicalInventory
  module Azure
    class Collector
      class Metrics < TopologicalInventory::Providers::Common::Metrics
        def initialize(port = 9394)
          super(port)
        end

        def default_prefix
          "topological_inventory_azure_collector_"
        end
      end
    end
  end
end
