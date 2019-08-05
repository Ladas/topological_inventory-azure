module TopologicalInventory::Azure
  class Parser
    module NetworkAdapter
      def parse_network_adapters(interface, scope)
        instance_id = interface.virtual_machine&.id
        device      = lazy_find(:vms, :source_ref => instance_id) if instance_id

        collections[:network_adapters].data << TopologicalInventoryIngressApiClient::NetworkAdapter.new(
          :source_ref          => interface.id,
          :mac_address         => interface.mac_address,
          :extra               => {
            :name                          => interface.name,
            :provisioning_state            => interface.provisioning_state,
            :enable_accelerated_networking => interface.enable_accelerated_networking,
            :enable_ipforwarding           => interface.enable_ipforwarding,
          },
          :subscription        => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
          :source_region       => lazy_find(:source_regions, :source_ref => interface.location),
          :orchestration_stack => nil,
          :device              => device
        )

        parse_network_adapter_ipaddresses(interface, scope)
        parse_network_adapter_tags(interface.id, interface.tags)
      end

      def parse_network_adapter_ipaddresses(interface, scope)
        interface.ip_configurations.each do |address|
          subnet = lazy_find(:subnets, :source_ref => address.subnet&.id) if address.subnet&.id

          collections[:ipaddresses].data << TopologicalInventoryIngressApiClient::Ipaddress.new(
            :source_ref      => address.id,
            :ipaddress       => address.private_ipaddress,
            :network_adapter => lazy_find(:network_adapters, :source_ref => interface.id),
            :subscription    => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
            :source_region   => lazy_find(:source_regions, :source_ref => interface.location),
            :subnet          => subnet,
            :kind            => "private",
            :extra           => {
              :primary                     => address.primary,
              :name                        => address.name,
              :provisioning_state          => address.provisioning_state,
              :private_ipaddress_version   => address.private_ipaddress_version,
              :private_ipallocation_method => address.private_ipallocation_method,
            }
          )
        end
      end

      def parse_network_adapter_tags(network_adapter_uid, tags)
        (tags || {}).each do |key, value|
          collections[:network_adapter_tags].data << TopologicalInventoryIngressApiClient::NetworkAdapterTag.new(
            :network_adapter => lazy_find(:network_adapters, :source_ref => network_adapter_uid),
            :tag             => lazy_find(:tags, :name => key, :value => value, :namespace => "azure")
          )
        end
      end
    end
  end
end
