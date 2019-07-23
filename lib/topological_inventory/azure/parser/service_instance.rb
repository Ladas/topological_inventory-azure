module TopologicalInventory::Azure
  class Parser
    module ServiceInstance
      def parse_service_instances(hash, scope)
        service_instance = hash[:service_instance]
        described_record = hash[:described_record]

        described_record_detail  = described_record&.record_detail
        described_record_outputs = described_record&.record_outputs
        service_plans_uuid       = "#{described_record_detail&.product_id}__#{described_record_detail&.provisioning_artifact_id}"\
                                     "__#{described_record_detail&.path_id}"

        service_offering_uuid = described_record_detail&.product_id

        service_offering      = lazy_find(:service_offerings, :source_ref => service_offering_uuid) if service_offering_uuid
        service_plan          = lazy_find(:service_plans, :source_ref => service_plans_uuid) if service_plans_uuid

        service_instance = TopologicalInventoryIngressApiClient::ServiceInstance.new(
          :source_ref        => service_instance.id,
          :name              => service_instance.name,
          :source_created_at => service_instance.created_time,
          :service_offering  => service_offering,
          :service_plan      => service_plan,
          :source_region     => lazy_find(:source_regions, :source_ref => scope[:region]),
          :extra             => {
            :arn                 => service_instance.arn,
            :type                => service_instance.type,
            :status              => service_instance.status,
            :status_message      => service_instance.status_message,
            :idempotency_token   => service_instance.idempotency_token,
            :last_record_id      => service_instance.last_record_id,
            :last_record_detail  => described_record_detail,
            :last_record_outputs => described_record_outputs,
          }
        )

        collections[:service_instances].data << service_instance
      end
    end
  end
end
