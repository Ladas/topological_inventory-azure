module TopologicalInventory
  module Azure
    module Connection
      class << self
        def compute(options)
          raw_connect(options.merge(:service => :Compute))
        end

        def resources(options)
          raw_connect(options.merge(:service => :Resources))
        end

        def subscriptions(options)
          raw_connect(options.merge(:service => :Subscriptions))
        end

        def all_subscriptions(options)
          raw_connect_direct(options.merge(:service => :Subscriptions, :version => "V2016_06_01", :client_name => "SubscriptionClient"))
        end

        private

        def raw_connect_direct(client_id:, client_secret:, tenant_id:, service:, version:, client_name:)
          require 'ms_rest_azure'
          require 'azure_mgmt_subscriptions'

          token_provider = ::MsRestAzure::ApplicationTokenProvider.new(tenant_id, client_id, client_secret)
          credentials    = ::MsRest::TokenCredentials.new(token_provider)
          ::Azure.const_get(service)::Mgmt.const_get(version).const_get(client_name).new(credentials)
        end

        def raw_connect(client_id:, client_secret:, tenant_id:, subscription_id:, service:)
          require 'ms_rest_azure'
          require 'azure_mgmt_resources'
          require 'azure_mgmt_compute'
          require 'azure_mgmt_network'

          credentials = {
            :tenant_id       => tenant_id,
            :client_id       => client_id,
            :client_secret   => client_secret,
            :subscription_id => subscription_id
          }

          # TODO(lsmola) what is the right version for azure cloud? Right now taking latest
          ::Azure.const_get(service)::Profiles::Latest::Mgmt::Client.new(credentials)
        end
      end
    end
  end
end
