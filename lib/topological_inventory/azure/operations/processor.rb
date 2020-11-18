require "topological_inventory/azure/logging"
require "topological_inventory/providers/common/operations/processor"

module TopologicalInventory
  module Azure
    module Operations
      class Processor < TopologicalInventory::Providers::Common::Operations::Processor
        include Logging

        def operation_class
          "#{Operations}::#{model}".safe_constantize
        end
      end
    end
  end
end
