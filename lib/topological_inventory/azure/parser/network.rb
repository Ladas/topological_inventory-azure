module TopologicalInventory::Azure
  class Parser
    module Network
      def parse_networks(network, scope)
        collections[:networks].data << TopologicalInventoryIngressApiClient::Network.new(
          :source_ref          => network.id,
          :name                => network.name,
          :cidr                => nil,
          :status              => network.provisioning_state == "Succeeded" ? "active" : "inactive",
          :extra               => {
            :enable_ddos_protection => network.enable_ddos_protection,
            :enable_vm_protection   => network.enable_vm_protection,
            :address_space          => network.address_space,

          },
          :subscription        => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
          :source_region       => lazy_find(:source_regions, :source_ref => network.location),
          :orchestration_stack => nil
        )

        parse_network_tags(network.id, network.tags)
        parse_subnets(network, scope)
      end

      def parse_network_tags(network_uid, tags)
        (tags || {}).each do |key, value|
          collections[:network_tags].data << TopologicalInventoryIngressApiClient::NetworkTag.new(
            :network => lazy_find(:networks, :source_ref => network_uid),
            :tag     => lazy_find(:tags, :name => key, :value => value, :namespace => "azure"),
          )
        end
      end

      def parse_subnets(network, scope)
        (network.subnets || []).each do |subnet|
          collections[:subnets].data << TopologicalInventoryIngressApiClient::Subnet.new(
            :source_ref          => subnet.id,
            :name                => subnet.name,
            :cidr                => subnet.address_prefix,
            :status              => subnet.provisioning_state,
            :extra               => {
              :private_endpoint_network_policies     => subnet.private_endpoint_network_policies,
              :private_link_service_network_policies => subnet.private_link_service_network_policies,
            },
            :cloud_network       => lazy_find(:cloud_networks, :source_ref => network.id),
            :subscription        => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
            :source_region       => lazy_find(:source_regions, :source_ref => network.location),
            :orchestration_stack => nil
          )
        end
      end
    end
  end
end
