module TopologicalInventory::Azure
  class Parser
    module Flavor
      def parse_flavors(flavor, _scope)
        f = TopologicalInventoryIngressApiClient::Flavor.new(
          :source_ref => flavor.name,
          :name       => flavor.name,
          :cpus       => flavor.number_of_cores,
          :disk_size  => flavor.resource_disk_size_in_mb * 1024**2,
          :disk_count => flavor.max_data_disk_count,
          :memory     => flavor.memory_in_mb * 1024**2,
          :extra      => {
            :attributes => {
              :max_data_disk_count      => flavor.max_data_disk_count,
              :memory_in_mb             => flavor.memory_in_mb,
              :number_of_cores          => flavor.number_of_cores,
              :os_disk_size_in_mb       => flavor.os_disk_size_in_mb,
              :resource_disk_size_in_mb => flavor.resource_disk_size_in_mb

            },
          }
        )

        collections[:flavors].data << f
      end
    end
  end
end
