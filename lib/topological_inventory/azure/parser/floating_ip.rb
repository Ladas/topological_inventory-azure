module TopologicalInventory::Azure
  class Parser
    module FloatingIp
      def parse_floating_ips(ip, scope)
        network_adapter = lazy_find(:network_adapters, :source_ref => floating_ip_network_port_id(ip)) if floating_ip_network_port_id(ip)

        collections[:ipaddresses].data << TopologicalInventoryIngressApiClient::Ipaddress.new(
          :source_ref          => ip.id,
          :ipaddress           => ip.ip_address || ip.name,
          :kind                => "elastic",
          :extra               => {
            :name                       => ip.name,
            :provisioning_state         => ip.provisioning_state,
            :public_ipaddress_version   => ip.public_ipaddress_version,
            :public_ipallocation_method => ip.public_ipallocation_method,
            :resource_guid              => ip.resource_guid,
            :type                       => ip.type,
            :idle_timeout_in_minutes    => ip.idle_timeout_in_minutes,
          },
          :source_region       => lazy_find(:source_regions, :source_ref => ip.location),
          :subscription        => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
          :orchestration_stack => nil,
          :network_adapter     => network_adapter,
        )

        parse_floating_ip_tags(ip.id, ip.ip_tags)
      end

      def parse_floating_ip_tags(floating_ip_uid, tags)
        tags.each do |tag|
          collections[:ipaddress_tags].data << TopologicalInventoryIngressApiClient::IpaddressTag.new(
            :ipaddress => lazy_find(:ipaddresses, :source_ref => floating_ip_uid),
            :tag       => lazy_find(:tags, :name => tag.key, :value => tag.value, :namespace => "azure"),
          )
        end
      end

      def floating_ip_network_port_id(ip)
        # Cutting last 2 / from the id, to get just the id of the network_port. ID looks like:
        # /subscriptions/{guid}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkInterfaces/vm1nic1/ipConfigurations/ip1
        # where id of the network port is
        # /subscriptions/{guid}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkInterfaces/vm1nic1
        cloud_subnet_network_port_id = ip.ip_configuration&.id
        cloud_subnet_network_port_id.split("/")[0..-3].join("/") if cloud_subnet_network_port_id
      end
    end
  end
end
