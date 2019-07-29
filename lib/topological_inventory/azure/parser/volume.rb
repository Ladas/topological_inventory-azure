module TopologicalInventory::Azure
  class Parser
    module Volume
      def parse_volumes(data, _scope)
        volume = if data.kind_of?(Hash)
                   parse_unmanaged_disk(data)
                 else
                   parse_managed_disk(data)
                 end

        collections[:volumes].data << volume
        # TODO(lsmola) parse volume_tags but first we need the modeling
      end

      private

      def parse_managed_disk(data)
        TopologicalInventoryIngressApiClient::Volume.new(
          :source_ref        => data.id,
          :name              => data.name || data.id,
          :state             => parse_volume_state(data.provisioning_state),
          :source_created_at => data.time_created,
          :size              => (data.disk_size_gb || 0) * 1024 ** 3,
          # TODO(lsmola) is there a volume_type concept in Azure?
          # :volume_type       => lazy_find(:volume_types, :source_ref => data.volume_type),
          :source_region => lazy_find(:source_regions, :source_ref => data.location)
        )
      end

      def parse_unmanaged_disk(data)
        uri = "#{data[:storage_account].primary_endpoints.blob}#{data[:container].name}/#{data[:blob].name}"
        TopologicalInventoryIngressApiClient::Volume.new(
          :source_ref        => uri,
          :name              => data[:blob].name || uri,
          :state             => nil, # TODO options here are .lease_status and .lease_state
          :source_created_at => nil,
          :source_updated_at => data[:blob].properties[:last_modified],
          :size              => data[:blob].properties[:content_length],
          # TODO(lsmola) is there a volume_type concept in Azure?
          # :volume_type       => lazy_find(:volume_types, :source_ref => data.volume_type),
          :source_region => lazy_find(:source_regions, :source_ref => data[:storage_account].location)
        )
      end

      def parse_volume_state(state)
        # TODO(lsmola) define allowed states in the OpenAPI spec, find the documented states, so far I've seen
        # Succeeded
        state
      end

      def parse_volume_attachment_state(state)
        # TODO(lsmola) define allowed states in the OpenAPI spec, find the documented states, so far I've seen
        # Unattached and Reserved
        state
      end
    end
  end
end
