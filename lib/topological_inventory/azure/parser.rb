require "active_support/inflector"
require "topological_inventory/azure/parser/flavor"
require "topological_inventory/azure/parser/floating_ip"
require "topological_inventory/azure/parser/network"
require "topological_inventory/azure/parser/network_adapter"
require "topological_inventory/azure/parser/security_group"
require "topological_inventory/azure/parser/source_region"
require "topological_inventory/azure/parser/vm"
require "topological_inventory/azure/parser/volume"
require "topological_inventory-ingress_api-client"
require "topological_inventory-ingress_api-client/collector.rb"
require "topological_inventory-ingress_api-client/collector/inventory_collection_storage.rb"

module TopologicalInventory
  module Azure
    class Parser
      include Parser::Flavor
      include Parser::FloatingIp
      include Parser::Network
      include Parser::NetworkAdapter
      include Parser::SecurityGroup
      include Parser::SourceRegion
      include Parser::Vm
      include Parser::Volume

      attr_accessor :connection, :collections, :resource_timestamp

      def initialize(connection = nil)
        self.connection         = connection
        self.resource_timestamp = Time.now.utc
        self.collections = TopologicalInventoryIngressApiClient::Collector::InventoryCollectionStorage.new
      end

      private

      def archive_entity(inventory_object, entity)
        source_deleted_at                  = entity.metadata&.deletionTimestamp || Time.now.utc
        inventory_object.source_deleted_at = source_deleted_at
      end

      def lazy_find(collection, reference, ref: :manager_ref)
        TopologicalInventoryIngressApiClient::InventoryObjectLazy.new(
          :inventory_collection_name => collection,
          :reference                 => reference,
          :ref                       => ref
        )
      end
    end
  end
end
