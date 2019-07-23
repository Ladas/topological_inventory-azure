module TopologicalInventory::Azure
  class Parser
    module ServiceOffering
      def parse_service_offerings(service_offering, scope)
        service_offering = TopologicalInventoryIngressApiClient::ServiceOffering.new(
          :source_ref        => service_offering.product_view_summary.product_id,
          :name              => service_offering.product_view_summary.name,
          :description       => nil,
          :source_created_at => service_offering.created_time,
          :source_region     => lazy_find(:source_regions, :source_ref => scope[:region]),
          :extra             => {
            :product_view_summary => service_offering.product_view_summary,
            :status               => service_offering.status,
            :product_arn          => service_offering.product_arn,
          }
        )

        collections[:service_offerings].data << service_offering
      end
    end
  end
end
