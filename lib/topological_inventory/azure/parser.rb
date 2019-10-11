require "topological_inventory/providers/common/collector/parser"

module TopologicalInventory
  module Azure
    class Parser < TopologicalInventory::Providers::Common::Collector::Parser
      require "topological_inventory/azure/parser/flavor"
      require "topological_inventory/azure/parser/floating_ip"
      require "topological_inventory/azure/parser/network"
      require "topological_inventory/azure/parser/network_adapter"
      require "topological_inventory/azure/parser/security_group"
      require "topological_inventory/azure/parser/source_region"
      require "topological_inventory/azure/parser/vm"
      require "topological_inventory/azure/parser/volume"

      include Parser::Flavor
      include Parser::FloatingIp
      include Parser::Network
      include Parser::NetworkAdapter
      include Parser::SecurityGroup
      include Parser::SourceRegion
      include Parser::Vm
      include Parser::Volume

      attr_accessor :connection

      def initialize(connection = nil)
        super()
        self.connection         = connection
      end

      private

      def archive_entity(inventory_object, entity)
        source_deleted_at                  = entity.metadata&.deletionTimestamp || Time.now.utc
        inventory_object.source_deleted_at = source_deleted_at
      end
    end
  end
end
