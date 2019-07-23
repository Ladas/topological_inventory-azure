module TopologicalInventory::Azure
  class Parser
    module Vm
      def parse_vms(instance, scope)
        # require 'byebug'; byebug if instance.tags.present?

        uid          = instance.id
        flavor       = lazy_find(:flavors, :source_ref => instance.hardware_profile.vm_size) if instance.hardware_profile.vm_size
        subscription = lazy_find(:subscriptions, :source_ref => scope[:subscription_id])

        power_state  = 'unknown' unless (power_state = raw_power_state(instance.instance_view))

        vm = TopologicalInventoryIngressApiClient::Vm.new(
          :source_ref   => uid,
          :uid_ems      => uid,
          :name         => instance.name || uid,
          :power_state  => parse_vm_power_state(power_state),
          :flavor       => flavor,
          :subscription => subscription,
          # :mac_addresses => parse_network(instance)[:mac_addresses],
        )

        collections[:vms].data << vm
        parse_vm_tags(uid, instance.tags)
      end

      private

      def raw_power_state(instance_view)
        instance_view&.statuses&.detect { |s| s.code.start_with?('PowerState/') }&.code
      end

      def parse_network(instance)
        network = {
          :fqdn                 => instance.public_dns_name,
          :private_ip_address   => instance.private_ip_address,
          :public_ip_address    => instance.public_ip_address,
          :mac_addresses        => [],
          :private_ip_addresses => [],
          :public_ip_addresses  => [],
        }

        (instance.network_interfaces || []).each do |interface|
          network[:mac_addresses] << interface.mac_address
          interface.private_ip_addresses.each do |private_ip|
            network[:private_ip_addresses] << private_ip.private_ip_address
            network[:public_ip_addresses] << private_ip&.association&.public_ip if private_ip&.association&.public_ip
          end
        end

        network
      end

      def parse_vm_tags(vm_uid, tags)
        (tags || []).each do |key, value|
          collections[:vm_tags].data << TopologicalInventoryIngressApiClient::VmTag.new(
            :vm  => lazy_find(:vms, :source_ref => vm_uid),
            :tag => lazy_find(:tags, :name => key, :value => value, :namespace => "azure"),
          )
        end
      end

      def parse_vm_power_state(state)
        case state
        when "PowerState/running"
          "on"
        when "PowerState/stopping"
          "powering_down"
        when "PowerState/deallocating"
          "terminating"
        when "PowerState/deallocated"
          "terminated"
        when "PowerState/stopped", "PowerState/starting"
          "off"
        else
          "unknown"
        end
      end
    end
  end
end
