module TopologicalInventory::Azure
  class Parser
    module Vm
      def parse_vms(data, scope)
        instance = data[:vm]
        uid      = instance.id

        flavor      = lazy_find(:flavors, :source_ref => instance.hardware_profile.vm_size) if instance.hardware_profile.vm_size
        power_state = 'unknown' unless (power_state = raw_power_state(instance.instance_view))

        vm = TopologicalInventoryIngressApiClient::Vm.new(
          :source_ref    => uid,
          :uid_ems       => uid,
          :name          => instance.name || uid,
          :power_state   => parse_vm_power_state(power_state),
          :flavor        => flavor,
          :source_region => lazy_find(:source_regions, :source_ref => instance.location),
          :subscription  => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
          :mac_addresses => parse_network(data)[:mac_addresses]
        )

        collections[:vms].data << vm
        parse_vm_tags(uid, instance.tags)
        parse_volume_attachments(uid, instance.storage_profile)
      end

      private

      def parse_volume_attachments(uid, storage_profile)
        parse_attachment(uid, storage_profile.os_disk)

        storage_profile.data_disks.each do |disk|
          parse_attachment(uid, disk)
        end
      end

      def parse_attachment(uid, disk)
        attachment_id = if disk.managed_disk
                          disk.managed_disk.id
                        elsif disk.vhd
                          disk.vhd.uri
                        end

        collections[:volume_attachments].data << TopologicalInventoryIngressApiClient::VolumeAttachment.new(
          :volume => lazy_find(:volumes, :source_ref => attachment_id),
          :vm     => lazy_find(:vms, :source_ref => uid),
          :device => nil,
          :state  => nil
        )
      end

      def raw_power_state(instance_view)
        instance_view&.statuses&.detect { |s| s.code.start_with?('PowerState/') }&.code
      end

      def parse_network(data)
        # TODO(lsmola) we can set this from .primary interface
        network = {
          :fqdn                 => nil,
          :private_ip_address   => nil,
          :public_ip_address    => nil,
          :mac_addresses        => [],
          :private_ip_addresses => [],
          :public_ip_addresses  => [],
        }

        (data[:network_interfaces] || []).each do |interface|
          network[:mac_addresses] << interface.mac_address
          interface.ip_configurations.each do |private_ip|
            network[:private_ip_addresses] << private_ip.private_ipaddress
            # TODO(lsmola) getting .public_ipaddress is another n+1 query, do we want it?
            # network[:public_ip_addresses] << nil
          end

          parse_vm_security_groups(data, interface)
        end

        network
      end

      def parse_vm_security_groups(data, interface)
        return unless interface.network_security_group

        collections[:vm_security_groups].data << TopologicalInventoryIngressApiClient::VmSecurityGroup.new(
          :vm             => lazy_find(:vms, :source_ref => data[:vm].id),
          :security_group => lazy_find(:security_groups, :source_ref => interface.network_security_group.id)
        )
      end

      def parse_vm_tags(vm_uid, tags)
        (tags || {}).each do |key, value|
          collections[:vm_tags].data << TopologicalInventoryIngressApiClient::VmTag.new(
            :vm  => lazy_find(:vms, :source_ref => vm_uid),
            :tag => lazy_find(:tags, :name => key, :value => value, :namespace => "azure")
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
