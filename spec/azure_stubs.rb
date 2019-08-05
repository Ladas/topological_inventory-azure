module AzureStubs
  def mocked_all_subscriptions_connection
    OpenStruct.new(
      :subscriptions => OpenStruct.new(
        :list => [
          OpenStruct.new(
            :subscription_id => "subscription1"
          )
        ]
      )
    )
  end

  def mocked_flavors
    [
      OpenStruct.new(
        :name                     => "flavor1",
        :number_of_cores          => 10,
        :resource_disk_size_in_mb => 1024,
        :max_data_disk_count      => 2,
        :memory_in_mb             => 2048
      )
    ]
  end

  def mocked_vms
    [
      {
        :vm                 => OpenStruct.new(
          :id               => "instanceid1",
          :name             => "Instance Name 1",
          :hardware_profile => OpenStruct.new(
            :vm_size => "flavor_1"
          ),
          :instance_view    => OpenStruct.new(
            :statuses => [
              OpenStruct.new(:code => "PowerState/stopping")
            ]
          ),
          :storage_profile  => OpenStruct.new(
            :os_disk    => OpenStruct.new(
              :managed_disk => OpenStruct.new(
                :id => "managed_os_disk_id_1"
              )
            ),
            :data_disks => [
              OpenStruct.new(
                :managed_disk => OpenStruct.new(
                  :id => "managed_disk_id_1"
                )
              ),
              OpenStruct.new(
                :vhd => OpenStruct.new(
                  :uri => "unmanaged_disk_uri_1"
                )
              )
            ]
          ),
          :tags             => {
            :old_name => "Good old VM",
            :new_name => "Good new VM"
          }
        ),
        :network_interfaces => [
          OpenStruct.new(
            :mac_address            => "macadr1",
            :ip_configurations      => [
              OpenStruct.new(
                :private_ipaddress => "10.10.10.1"
              ),
              OpenStruct.new(
                :private_ipaddress => "11.10.10.1"
              ),
            ],
            :network_security_group => OpenStruct.new(
              :id => "security_group_id"
            )
          )
        ],
      }
    ]
  end

  def mocked_volumes
    [
      OpenStruct.new(
        :id                 => "volumeid1",
        :name               => "volume name 1",
        :provisioning_state => "Succeeded",
        :time_created       => "2019-10-10 20:42",
        :disk_size_gb       => 100,
        :managed_by         => "vm_id_1",
        :disk_state         => "Attached",
        :location           => "useast20"
      ),
      {
        :storage_account => OpenStruct.new(
          :primary_endpoints => OpenStruct.new(
            :blob => "https://my.blob.azure.com/"
          ),
          :location          => "useast20"
        ),
        :container       => OpenStruct.new(
          :name => "unmanaged_storage_container"
        ),
        :blob            => OpenStruct.new(
          :name       => "my_blob",
          :properties => {
            :content_length => 30 * 1024**3,
            :last_modified  => "2012-12-12 20:20"
          }
        )
      }
    ]
  end

  def mocked_source_regions
    [
      OpenStruct.new(
        :name         => "useast20",
        :display_name => "Nice east of the US sector 20"
      )
    ]
  end

  def mocked_networks
    [
      OpenStruct.new(
        :id                 => "network_id",
        :name               => "network name",
        :provisioning_state => "Succeeded",
        :location           => "useast20",
        :subnets            => [
          OpenStruct.new(
            :id                 => "subnet1_id",
            :name               => "subnet1",
            :address_prefix     => "10.10.10.10/30",
            :provisioning_state => "Succeeded"
          )
        ]
      )
    ]
  end

  def mocked_network_adapters
    [
      OpenStruct.new(
        :virtual_machine        => OpenStruct.new(
          :id => "vm_id_1"
        ),
        :id                     => "interface_1",
        :mac_address            => "mac_addr_1",
        :name                   => "eth0",
        :location               => "useast20",
        :ip_configurations      => [
          OpenStruct.new(
            :private_ipaddress => "10.10.10.1",
            :subnet            => OpenStruct.new(
              :id => "subnet_id_1"
            ),
            :name              => "ip1",
            :primary           => true
          ),
          OpenStruct.new(
            :private_ipaddress => "11.10.10.1",
            :subnet            => OpenStruct.new(
              :id => "subnet_id_1"
            ),
            :name              => "ip2",
            :primary           => false
          ),
        ],
        :network_security_group => OpenStruct.new(
          :id => "security_group_id"
        ),
        :tags                   => {
          :env => "super_prod"
        }
      )
    ]
  end

  def mocked_floating_ips
    [
      OpenStruct.new(
        :id               => "floating_ip_id_1",
        :name             => "floating_ip_name_1",
        :ip_configuration => OpenStruct.new(
          :id => "/subscriptions/guid/resourceGroups/resource_group_name/providers/Microsoft.Network/networkInterfaces/vm1nic1/ipConfigurations/ip1"
        ),
        :ip_address       => "10.10.10.3",
        :location         => "useast20",
        :ip_tags          => {
          :env   => "prod",
          :owner => "CEO",
        }
      )
    ]
  end

  def mocked_security_groups
    [
      OpenStruct.new(
        :id                 => "security_group_id_1",
        :name               => "security_group_name_1",
        :provisioning_state => "Succeeded",
        :location           => "useast20",
        :tags               => {
          :dimension => "42"
        }
      )
    ]
  end
end
