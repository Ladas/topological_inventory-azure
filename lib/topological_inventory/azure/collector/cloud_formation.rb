module TopologicalInventory
  module Azure
    class Collector
      module CloudFormation
        def orchestration_stacks(scope)
          cloud_formation_connection(scope).client.describe_stacks[:stacks]
        end

        private

        def orchestration_stack_resources(stack_name, scope)
          cloud_formation_connection(scope).client.list_stack_resources(:stack_name => stack_name).try(:stack_resource_summaries) || []
        rescue => e
          log.warn("Couldn't fetch 'list_stack_resources' from CloudFormation, message: #{e.message}")
          nil
        end

        def orchestration_stack_template(stack_name, scope)
          cloud_formation_connection(scope).client.get_template(:stack_name => stack_name).template_body
        rescue => e
          log.warn("Couldn't fetch 'get_template' from CloudFormation, message: #{e.message}")
          nil
        end
      end
    end
  end
end
