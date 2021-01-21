require "concurrent"
require "topological_inventory/providers/common/collector"
require "topological_inventory/azure/connection"
require "topological_inventory/azure/parser"
require "topological_inventory/azure/iterator"
require "topological_inventory/azure/logging"

module TopologicalInventory
  module Azure
    class Collector < ::TopologicalInventory::Providers::Common::Collector
      include Logging

      require "topological_inventory/azure/collector/compute"
      require "topological_inventory/azure/collector/network"

      include Azure::Collector::Compute
      include Azure::Collector::Network

      def initialize(source, client_id, client_secret, tenant_id, metrics,
                     default_limit: 1_000, poll_time: 30, standalone_mode: true)
        super(source,
              :default_limit   => default_limit,
              :poll_time       => poll_time,
              :standalone_mode => standalone_mode)

        self.client_id     = client_id
        self.client_secret = client_secret
        self.tenant_id     = tenant_id
        self.metrics       = metrics
      end

      def collect!
        until finished?
          begin
            entity_types.each do |entity_type|
              metrics.record_refresh_timing(:entity_type => entity_type) do
                process_entity(entity_type)
              end
            end
          ensure
            standalone_mode ? sleep(poll_time) : stop
          end
        end
      end

      private

      attr_accessor :log, :metrics, :client_id, :client_secret, :tenant_id

      def process_entity(entity_type)
        refresh_state_uuid, refresh_state_started_at, refresh_state_part_collected_at = SecureRandom.uuid, Time.now.utc, nil

        logger.collecting(:start, source, entity_type, refresh_state_uuid)
        parser      = create_parser

        count, total_parts, sweep_scope = 0, 0, Set.new([entity_type.to_sym])

        all_subscriptions_connection.subscriptions.list.each do |subscription|
          scope = {:subscription_id => subscription.subscription_id}

          # Collect, parse and save entity data
          parser, count, total_parts, sweep_scope, refresh_state_part_collected_at = save_entity(entity_type, refresh_state_uuid, parser, scope, count, total_parts, sweep_scope, refresh_state_part_collected_at)

          # Collect, parse and save related entities data, if there are any
          (related_entities[entity_type.to_sym] || []).each do |related_entity_type|
            parser, count, total_parts, sweep_scope, refresh_state_part_collected_at = save_entity(related_entity_type, refresh_state_uuid, parser, scope, count, total_parts, sweep_scope, refresh_state_part_collected_at)
          end
        end

        if count > 0
          # Save the rest
          refresh_state_part_uuid = SecureRandom.uuid
          total_parts += save_inventory(parser.collections.values, inventory_name, schema_name, refresh_state_uuid, refresh_state_part_uuid, refresh_state_part_collected_at)
          sweep_scope.merge(parser.collections.values.map(&:name))
        end
        logger.collecting(:finish, source, entity_type, refresh_state_uuid, total_parts)

        sweep_scope = sweep_scope.to_a
        logger.sweeping(:start, source, sweep_scope, refresh_state_uuid)
        sweep_inventory(inventory_name, schema_name, refresh_state_uuid, total_parts, sweep_scope, refresh_state_started_at)
        logger.sweeping(:finish, source, sweep_scope, refresh_state_uuid)
      rescue => e
        metrics.record_error
        logger.collecting_error(source, entity_type, refresh_state_uuid, e)
      end

      # Collect, parse and save entity data
      def save_entity(entity_type, refresh_state_uuid, parser, scope, count, total_parts, sweep_scope, refresh_state_part_collected_at)
        send(entity_type.to_s, scope).each do |entity|
          refresh_state_part_collected_at = Time.now.utc
          count += 1
          parser.send("parse_#{entity_type}", entity, scope)

          if count >= limits[entity_type]
            count                   = 0
            refresh_state_part_uuid = SecureRandom.uuid
            total_parts             += save_inventory(parser.collections.values, inventory_name, schema_name, refresh_state_uuid, refresh_state_part_uuid, refresh_state_part_collected_at)
            sweep_scope.merge(parser.collections.values.map(&:name))

            parser = create_parser
          end
        end

        return parser, count, total_parts, sweep_scope, refresh_state_part_collected_at
      end

      # Entities that should be always refreshed and sweeped together, e.g. if by scanning Vms, we're also creating
      # network adapters
      def related_entities
        {
          :network_adapters => [:floating_ips]
        }
      end

      def create_parser
        Parser.new
      end

      def compute_entity_types
        %w[vms source_regions flavors volumes]
      end

      def network_entity_types
        %w[networks network_adapters security_groups]
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
