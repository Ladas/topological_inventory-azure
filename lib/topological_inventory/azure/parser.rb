require "active_support/inflector"
require "topological_inventory/azure/parser/source_region"
require "topological_inventory/azure/parser/flavor"
require "topological_inventory/azure/parser/vm"
require "topological_inventory/azure/parser/volume"
require "topological_inventory/azure/parser/volume_type"
require "topological_inventory-ingress_api-client"
require "topological_inventory-ingress_api-client/collector.rb"
require "topological_inventory-ingress_api-client/collector/inventory_collection_storage.rb"

module TopologicalInventory
  module Azure
    class Parser
      include Parser::SourceRegion
      include Parser::Flavor
      include Parser::Vm
      include Parser::Volume
      include Parser::VolumeType

      attr_accessor :connection, :collections, :resource_timestamp

      def initialize(connection = nil)
        self.connection         = connection
        self.resource_timestamp = Time.now.utc
        self.collections = TopologicalInventoryIngressApiClient::Collector::InventoryCollectionStorage.new
      end

      private

      def parse_base_item(entity)
        {
          :name               => entity.metadata.name,
          :resource_version   => entity.metadata.resourceVersion,
          :resource_timestamp => resource_timestamp,
          :source_created_at  => entity.metadata.creationTimestamp,
          :source_ref         => entity.metadata.uid,
        }
      end

      def archive_entity(inventory_object, entity)
        source_deleted_at                  = entity.metadata&.deletionTimestamp || Time.now.utc
        inventory_object.source_deleted_at = source_deleted_at
      end

      def lazy_find(collection, reference, ref: :manager_ref)
        TopologicalInventoryIngressApiClient::InventoryObjectLazy.new(
          :inventory_collection_name => collection,
          :reference                 => reference,
          :ref                       => ref,
        )
      end

      def get_from_tags(tags, tag_name)
        tags.detect { |tag| tag.key.downcase == tag_name.to_s.downcase }&.value
      end
    end
  end
end
