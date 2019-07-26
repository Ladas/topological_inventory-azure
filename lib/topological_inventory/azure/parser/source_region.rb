module TopologicalInventory::Azure
  class Parser
    module SourceRegion
      def parse_source_regions(region, _scope)
        region = TopologicalInventoryIngressApiClient::SourceRegion.new(
          :source_ref => region.name,
          :name       => region.display_name,
          :endpoint   => nil
        )

        collections[:source_regions].data << region
      end
    end
  end
end
