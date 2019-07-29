module TopologicalInventory::Azure
  class Parser
    module Volume
      def parse_volumes(data, _scope)
        volume = TopologicalInventoryIngressApiClient::Volume.new(
          :source_ref        => data.id,
          :name              => data.name || data.id,
          :state             => parse_volume_state(data.provisioning_state),
          :source_created_at => data.time_created,
          :size              => (data.disk_size_gb || 0) * 1024**3,
          # TODO(lsmola) is there a volume_type concept in Azure?
          # :volume_type       => lazy_find(:volume_types, :source_ref => data.volume_type),
          :source_region     => lazy_find(:source_regions, :source_ref => data.location)
        )

        collections[:volumes].data << volume
        parse_volume_attachments(data)
        # TODO(lsmola) parse volume_tags but first we need the modeling
      end

      private

      def parse_volume_attachments(data)
        return unless data.managed_by

        volume_attachment = TopologicalInventoryIngressApiClient::VolumeAttachment.new(
          :volume => lazy_find(:volumes, :source_ref => data.id),
          :vm     => lazy_find(:vms, :source_ref => data.managed_by),
          :device => nil,
          :state  => parse_volume_attachment_state(data.disk_state)
        )

        collections[:volume_attachments].data << volume_attachment
      end

      def parse_volume_state(state)
        # TODO(lsmola) define allowed states in the OpenAPI spec
        case state
        when "Succeeded", "Failed"
          state
        else
          "unknown"
        end
      end

      def parse_volume_attachment_state(state)
        # TODO(lsmola) define allowed states in the OpenAPI spec
        case state
        when "Unattached", "Attached"
          state
        else
          "unknown"
        end
      end
    end
  end
end
