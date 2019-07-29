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
            :new_name => "Good new VM"}

        ),
        :network_interfaces => OpenStruct.new(
          :mac_address          => "macadr1",
          :private_ip_addresses => [
            OpenStruct.new(
              :private_ipaddress => "10.10.10.1"
            ),
            OpenStruct.new(
              :private_ipaddress => "11.10.10.1"
            ),
          ]
        ),
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
            :blob => "https://my.blob.azure.com/",
          ),
          :location          => "useast20"
        ),
        :container       => OpenStruct.new(
          :name => "unmanaged_storage_container"
        ),
        :blob            => OpenStruct.new(
          :name       => "my_blob",
          :properties => {
            :content_length => 30 * 1024 ** 3,
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
end
