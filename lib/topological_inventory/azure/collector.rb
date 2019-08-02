require "concurrent"
require "topological_inventory-ingress_api-client/collector"
require "topological_inventory/azure/connection"
require "topological_inventory/azure/parser"
require "topological_inventory/azure/iterator"
require "topological_inventory/azure/logging"
require "topological_inventory-ingress_api-client"

module TopologicalInventory
  module Azure
    class Collector < ::TopologicalInventoryIngressApiClient::Collector
      include Logging

      require "topological_inventory/azure/collector/compute"
      require "topological_inventory/azure/collector/network"

      include Azure::Collector::Compute
      include Azure::Collector::Network

      def initialize(source, client_id, client_secret, tenant_id, metrics, default_limit: 1_000, poll_time: 5)
        super(source,
              :default_limit => default_limit,
              :poll_time     => poll_time)

        self.client_id     = client_id
        self.client_secret = client_secret
        self.tenant_id     = tenant_id
        self.metrics       = metrics
      end

      def collect!
        loop do
          begin
            entity_types.each do |entity_type|
              process_entity(entity_type)
            end
          rescue StandardError => e
            logger.error(e)
            metrics.record_error
          ensure
            sleep(30)
          end
        end
      end

      private

      attr_accessor :log, :metrics, :client_id, :client_secret, :tenant_id

      def process_entity(entity_type)
        parser      = create_parser
        total_parts = 0
        sweep_scope = Set.new([entity_type.to_sym])

        refresh_state_uuid = SecureRandom.uuid
        logger.info("Collecting #{entity_type} with :refresh_state_uuid => '#{refresh_state_uuid}'...")

        count = 0

        all_subscriptions_connection.subscriptions.list.each do |subscription|
          scope = {:subscription_id => subscription.subscription_id}

          send(entity_type.to_s, scope).each do |entity|
            count += 1
            parser.send("parse_#{entity_type}", entity, scope)

            next unless count >= limits[entity_type]

            count                   = 0
            refresh_state_part_uuid = SecureRandom.uuid
            total_parts += save_inventory(parser.collections.values, inventory_name, schema_name, refresh_state_uuid, refresh_state_part_uuid)
            sweep_scope.merge(parser.collections.values.map(&:name))

            parser = create_parser
          end
        end

        if count > 0
          # Save the rest
          refresh_state_part_uuid = SecureRandom.uuid
          total_parts += save_inventory(parser.collections.values, inventory_name, schema_name, refresh_state_uuid, refresh_state_part_uuid)
          sweep_scope.merge(parser.collections.values.map(&:name))
        end

        logger.info("Collecting #{entity_type} with :refresh_state_uuid => '#{refresh_state_uuid}'...Complete - Parts [#{total_parts}]")

        sweep_scope = sweep_scope.to_a
        logger.info("Sweeping inactive records for #{sweep_scope} with :refresh_state_uuid => '#{refresh_state_uuid}'...")

        sweep_inventory(inventory_name, schema_name, refresh_state_uuid, total_parts, sweep_scope)

        logger.info("Sweeping inactive records for #{sweep_scope} with :refresh_state_uuid => '#{refresh_state_uuid}'...Complete")
      end

      def create_parser
        Parser.new
      end

      def compute_entity_types
        %w[vms source_regions flavors volumes]
      end

      def network_entity_types
        %w[floating_ips networks network_adapters security_groups]
      end

      def endpoint_types
        %w[network compute]
      end

      def connection_for_entity_type(entity_type, scope)
        endpoint_types.each do |endpoint|
          return send("#{endpoint}_connection", scope) if send("#{endpoint}_entity_types").include?(entity_type)
        end
        nil
      end

      def azure_resources
        # with_shared_token { |token| @azure_resources ||= manager.connect(:token => token) }
      end

      def all_subscriptions_connection
        Connection.all_subscriptions(connection_attributes)
      end

      def subscriptions_connection(scope)
        Connection.subscriptions(connection_attributes.merge(scope))
      end

      def compute_connection(scope)
        Connection.compute(connection_attributes.merge(scope))
      end

      def network_connection(scope)
        Connection.network(connection_attributes.merge(scope))
      end

      def resources_connection(scope)
        Connection.resources(connection_attributes.merge(scope))
      end

      def storage_connection(scope)
        Connection.storage(connection_attributes.merge(scope))
      end

      def connection_attributes
        {:client_id => client_id, :client_secret => client_secret, :tenant_id => tenant_id}
      end

      def with_shared_token
        # TODO(lsmola) figure out how to reuse token for all calls
        client = yield @token
        @token ||= client.credentials
        client
      end

      def resource_group_name(ems_ref)
        if (match = ems_ref.match(%r{/subscriptions/[^/]+/resourceGroups/(?<name>[^/]+)/.+}i))
          match[:name].downcase
        end
      end

      def resource_group_id(ems_ref)
        if (match = ems_ref.match(%r{(?<id>/subscriptions/[^/]+/resourceGroups/[^/]+)/.+}i))
          match[:id].downcase
        end
      end

      def network_interface_name(ems_ref)
        if (match = ems_ref.match(%r{/subscriptions/.*?/networkInterfaces/(?<name>.*?)$}i))
          match[:name].downcase
        end
      end
    end
  end
end
