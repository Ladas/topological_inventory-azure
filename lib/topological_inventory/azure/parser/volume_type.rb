module TopologicalInventory::Azure
  class Parser
    module VolumeType
      def parse_volume_types(data, _scope)
        attributes = data.dig("product", "attributes") || {}
        return unless attributes['volumeType']

        uid         = parse_volume_type_uid(attributes)
        volume_type = TopologicalInventoryIngressApiClient::VolumeType.new(
          :source_ref  => uid,
          :name        => uid,
          :description => attributes["volumeType"],
          :extra       => {
            :storageMedia  => attributes["storageMedia"],
            :volumeType    => attributes["volumeType"],
            :maxIopsvolume => attributes["maxIopsvolume"],
            :maxVolumeSize => attributes["maxVolumeSize"],
          }
        )

        collections[:volume_types].data << volume_type
      end

      def parse_volume_type_uid(attributes)
        usage_type = attributes["usagetype"]
        match      = /.*EBS\:VolumeUsage\.(.*)$/.match(usage_type)

        return 'standard' unless match

        match[1]
      end

      def parse_volume_type_source_ref(source_ref)
        case source_ref
        when "piops"
          "io1" # For some reason the 'io1' is called 'piops' in pricint data?
        else
          source_ref
        end
      end
    end
  end
end
