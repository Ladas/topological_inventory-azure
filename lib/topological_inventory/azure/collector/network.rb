module TopologicalInventory
  module Azure
    class Collector
      module Network
        def floating_ips(scope)
          network_connection(scope).public_ipaddresses.list_all
        end

        def security_groups(scope)
          network_connection(scope).network_security_groups.list_all
        end

        def networks(scope)
          network_connection(scope).virtual_networks.list_all
        end

        def network_adapters(scope)
          network_connection(scope).network_interfaces.list_all
        end
      end
    end
  end
end
