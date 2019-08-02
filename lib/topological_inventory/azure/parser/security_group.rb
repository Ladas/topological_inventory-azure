module TopologicalInventory::Azure
  class Parser
    module SecurityGroup
      def parse_security_groups(sg, scope)
        collections[:security_groups].data << TopologicalInventoryIngressApiClient::SecurityGroup.new(
          :source_ref          => sg.id,
          :name                => sg.name || sg.id,
          :description         => nil,
          :extra               => {
            # TODO(lsmola) there is no to_h method, we'll need to parse these:wq
            # :security_rules         => sg.security_rules,
            # :default_security_rules => sg.default_security_rules,
            :provisioning_state     => sg.provisioning_state,
          },
          :subscription        => lazy_find(:subscriptions, :source_ref => scope[:subscription_id]),
          :source_region       => lazy_find(:source_regions, :source_ref => sg.location),
          :orchestration_stack => nil,
          :network             => nil,
        )

        parse_security_group_tags(sg.id, sg.tags)
      end

      def parse_security_group_tags(security_group_uid, tags)
        (tags || {}).each do |key, value|
          collections[:security_group_tags].data << TopologicalInventoryIngressApiClient::SecurityGroupTag.new(
            :security_group => lazy_find(:security_groups, :source_ref => security_group_uid),
            :tag            => lazy_find(:tags, :name => key, :value => value, :namespace => "azure"),
          )
        end
      end
    end
  end
end
