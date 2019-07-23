module TopologicalInventory::Azure
  class Parser
    module Volume
      def parse_volumes(data, scope)
        volume = TopologicalInventoryIngressApiClient::Volume.new(
          :source_ref        => data.volume_id,
          :name              => get_from_tags(data.tags, :name) || data.volume_id,
          :state             => parse_volume_state(data.state),
          :source_created_at => data.create_time,
          :size              => (data.size || 0) * 1024**3,
          :volume_type       => lazy_find(:volume_types, :source_ref => data.volume_type),
          :source_region     => lazy_find(:source_regions, :source_ref => scope[:region]),
        )

        collections[:volumes].data << volume
        parse_volume_attachments(data)
      end

      private

      def parse_volume_attachments(data)
        (data.attachments || []).each do |attachment|
          volume_attachment = TopologicalInventoryIngressApiClient::VolumeAttachment.new(
            :volume => lazy_find(:volumes, :source_ref => data.volume_id),
            :vm     => lazy_find(:vms, :source_ref => attachment.instance_id),
            :device => attachment.device,
            :state  => parse_volume_attachment_state(attachment.state),
          )

          collections[:volume_attachments].data << volume_attachment
        end
      end

      def parse_volume_state(state)
        case state
        when "creating", "available", "in-use", "deleting", "deleted", "error"
          state
        else
          "unknown"
        end
      end

      def parse_volume_attachment_state(state)
        case state
        when "attaching", "attached", "detaching"
          state
        else
          "unknown"
        end
      end
    end
  end
end
