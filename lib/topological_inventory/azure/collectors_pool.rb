require "topological_inventory/providers/common/collectors_pool"
require "topological_inventory/azure/collector"
require "topological_inventory/azure/logging"

module TopologicalInventory::Azure
  class CollectorsPool < TopologicalInventory::Providers::Common::CollectorsPool
    include Logging

    def initialize(config_name, metrics)
      super
    end

    def path_to_config
      File.expand_path("../../../config", File.dirname(__FILE__))
    end

    def path_to_secrets
      File.expand_path("../../../secret", File.dirname(__FILE__))
    end

    def source_valid?(source, secret)
      missing_data = [source.source,
                      secret["username"],
                      secret["password"],
                      secret["tenant_id"]].select do |data|
        data.to_s.strip.blank?
      end
      missing_data.empty?
    end

    def new_collector(source, secret)
      TopologicalInventory::Azure::Collector.new(source.source, secret['username'], secret['password'], secret['tenant_id'], metrics, :standalone_mode => false)
    end
  end
end
