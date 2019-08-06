require "topological_inventory/azure/collector/application_metrics"
require_relative 'azure_stubs'

RSpec.describe TopologicalInventory::Azure::Collector do
  include AzureStubs

  it "collects and parses vms" do
    parser = collect_and_parse(:vms)

    expect(format_hash(:vms, parser)).to(
      match_array(
        [
          {:flavor        =>
                             {:inventory_collection_name => :flavors,
                              :reference                 => {:source_ref => "flavor_1"},
                              :ref                       => :manager_ref},
           :mac_addresses => ["macadr1"],
           :name          => "Instance Name 1",
           :power_state   => "powering_down",
           :source_ref    => "instanceid1",
           :source_region =>
                             {:inventory_collection_name => :source_regions,
                              :reference                 => {:source_ref => nil},
                              :ref                       => :manager_ref},
           :subscription  =>
                             {:inventory_collection_name => :subscriptions,
                              :reference                 => {:source_ref => "subscription1"},
                              :ref                       => :manager_ref},
           :uid_ems       => "instanceid1"}
        ]
      )
    )

    expect(format_hash(:volume_attachments, parser)).to(
      match_array(
        [
          {:vm     =>
                      {:inventory_collection_name => :vms,
                       :reference                 => {:source_ref => "instanceid1"},
                       :ref                       => :manager_ref},
           :volume =>
                      {:inventory_collection_name => :volumes,
                       :reference                 => {:source_ref => "managed_os_disk_id_1"},
                       :ref                       => :manager_ref}},
          {:vm     =>
                      {:inventory_collection_name => :vms,
                       :reference                 => {:source_ref => "instanceid1"},
                       :ref                       => :manager_ref},
           :volume =>
                      {:inventory_collection_name => :volumes,
                       :reference                 => {:source_ref => "managed_disk_id_1"},
                       :ref                       => :manager_ref}},
          {:vm     =>
                      {:inventory_collection_name => :vms,
                       :reference                 => {:source_ref => "instanceid1"},
                       :ref                       => :manager_ref},
           :volume =>
                      {:inventory_collection_name => :volumes,
                       :reference                 => {:source_ref => "unmanaged_disk_uri_1"},
                       :ref                       => :manager_ref}}
        ]
      )
    )

    expect(format_hash(:vm_tags, parser)).to(
      match_array(
        [{:tag =>
                  {:inventory_collection_name => :tags,
                   :reference                 => {:name => :old_name, :value => "Good old VM", :namespace => "azure"},
                   :ref                       => :manager_ref},
          :vm  =>
                  {:inventory_collection_name => :vms,
                   :reference                 => {:source_ref => "instanceid1"},
                   :ref                       => :manager_ref}},
         {:tag =>
                  {:inventory_collection_name => :tags,
                   :reference                 => {:name => :new_name, :value => "Good new VM", :namespace => "azure"},
                   :ref                       => :manager_ref},
          :vm  =>
                  {:inventory_collection_name => :vms,
                   :reference                 => {:source_ref => "instanceid1"},
                   :ref                       => :manager_ref}}]
      )
    )

    expect(format_hash(:vm_security_groups, parser)).to(
      match_array(
        [
          {:security_group =>
                              {:inventory_collection_name => :security_groups,
                               :reference                 => {:source_ref => "security_group_id"},
                               :ref                       => :manager_ref},
           :vm             =>
                              {:inventory_collection_name => :vms,
                               :reference                 => {:source_ref => "instanceid1"},
                               :ref                       => :manager_ref}}
        ]
      )
    )
  end

  it "collects and parses volumes" do
    parser = collect_and_parse(:volumes)

    expect(format_hash(:volumes, parser)).to(
      match_array(
        [
          {:name              => "volume name 1",
           :size              => 107374182400,
           :source_created_at => "2019-10-10 20:42",
           :source_ref        => "volumeid1",
           :source_region     =>
                                 {:inventory_collection_name => :source_regions,
                                  :reference                 => {:source_ref => "useast20"},
                                  :ref                       => :manager_ref},
           :state             => "Succeeded",
           :subscription      =>
                                 {:inventory_collection_name => :subscriptions,
                                  :reference                 => {:source_ref => "subscription1"},
                                  :ref                       => :manager_ref}},
          {:name          => "my_blob",
           :size          => 32212254720,
           :source_ref    => "https://my.blob.azure.com/unmanaged_storage_container/my_blob",
           :source_region =>
                             {:inventory_collection_name => :source_regions,
                              :reference                 => {:source_ref => "useast20"},
                              :ref                       => :manager_ref},
           :subscription  =>
                             {:inventory_collection_name => :subscriptions,
                              :reference                 => {:source_ref => "subscription1"},
                              :ref                       => :manager_ref}}
        ]
      )
    )
  end

  it "collects and parses source_regions" do
    parser = collect_and_parse(:source_regions)

    expect(format_hash(:source_regions, parser)).to(
      match_array(
        [
          {:name => "Nice east of the US sector 20", :source_ref => "useast20"}
        ]
      )
    )
  end

  it "collects and parses flavors" do
    parser = collect_and_parse(:flavors)

    expect(format_hash(:flavors, parser)).to(
      match_array(
        [
          {:cpus       => 10,
           :disk_count => 2,
           :disk_size  => 1024 * 1024**2,
           :extra      =>
                          {:attributes =>
                                          {:max_data_disk_count      => 2,
                                           :memory_in_mb             => 2048,
                                           :number_of_cores          => 10,
                                           :os_disk_size_in_mb       => nil,
                                           :resource_disk_size_in_mb => 1024}},
           :memory     => 2048 * 1024**2,
           :name       => "flavor1",
           :source_ref => "flavor1"}
        ]
      )
    )
  end

  it "collects and parses networks" do
    parser = collect_and_parse(:networks)

    expect(format_hash(:networks, parser)).to(
      match_array(
        [
          {:extra         =>
                             {:enable_ddos_protection => nil,
                              :enable_vm_protection   => nil,
                              :address_space          => nil},
           :name          => "network name",
           :source_ref    => "network_id",
           :source_region =>
                             {:inventory_collection_name => :source_regions,
                              :reference                 => {:source_ref => "useast20"},
                              :ref                       => :manager_ref},
           :status        => "active",
           :subscription  =>
                             {:inventory_collection_name => :subscriptions,
                              :reference                 => {:source_ref => "subscription1"},
                              :ref                       => :manager_ref}}
        ]
      )
    )

    expect(format_hash(:subnets, parser)).to(
      match_array(
        [
          {:cidr          => "10.10.10.10/30",
           :extra         =>
                             {:private_endpoint_network_policies     => nil,
                              :private_link_service_network_policies => nil},
           :name          => "subnet1",
           :network       =>
                             {:inventory_collection_name => :networks,
                              :reference                 => {:source_ref => "network_id"},
                              :ref                       => :manager_ref},
           :source_ref    => "subnet1_id",
           :source_region =>
                             {:inventory_collection_name => :source_regions,
                              :reference                 => {:source_ref => "useast20"},
                              :ref                       => :manager_ref},
           :status        => "Succeeded",
           :subscription  =>
                             {:inventory_collection_name => :subscriptions,
                              :reference                 => {:source_ref => "subscription1"},
                              :ref                       => :manager_ref}}
        ]
      )
    )
  end

  it "collects and parses network_adapters" do
    parser = collect_and_parse(:network_adapters)

    expect(format_hash(:network_adapters, parser)).to(
      match_array(
        [
          {:device      =>
                           {:inventory_collection_name => :vms,
                            :reference                 => {:source_ref => "vm_id_1"},
                            :ref                       => :manager_ref},
           :extra       =>
                           {:name                          => "eth0",
                            :provisioning_state            => nil,
                            :enable_accelerated_networking => nil,
                            :enable_ipforwarding           => nil},
           :mac_address => "mac_addr_1",
           :source_ref  => "interface_1"}
        ]
      )
    )

    expect(format_hash(:network_adapter_tags, parser)).to(
      match_array(
        [
          {:network_adapter =>
                               {:inventory_collection_name => :network_adapters,
                                :reference                 => {:source_ref => "interface_1"},
                                :ref                       => :manager_ref},
           :tag             =>
                               {:inventory_collection_name => :tags,
                                :reference                 => {:name => :env, :value => "super_prod", :namespace => "azure"},
                                :ref                       => :manager_ref}}
        ]
      )
    )

    expect(format_hash(:ipaddresses, parser)).to(
      match_array(
        [
          {:extra           =>
                               {:primary                     => true,
                                :name                        => "ip1",
                                :provisioning_state          => nil,
                                :private_ipaddress_version   => nil,
                                :private_ipallocation_method => nil},
           :ipaddress       => "10.10.10.1",
           :kind            => "private",
           :network_adapter =>
                               {:inventory_collection_name => :network_adapters,
                                :reference                 => {:source_ref => "interface_1"},
                                :ref                       => :manager_ref},
           :source_region   =>
                               {:inventory_collection_name => :source_regions,
                                :reference                 => {:source_ref => "useast20"},
                                :ref                       => :manager_ref},
           :subnet          =>
                               {:inventory_collection_name => :subnets,
                                :reference                 => {:source_ref => "subnet_id_1"},
                                :ref                       => :manager_ref},
           :subscription    =>
                               {:inventory_collection_name => :subscriptions,
                                :reference                 => {:source_ref => "subscription1"},
                                :ref                       => :manager_ref}},
          {:extra           =>
                               {:primary                     => false,
                                :name                        => "ip2",
                                :provisioning_state          => nil,
                                :private_ipaddress_version   => nil,
                                :private_ipallocation_method => nil},
           :ipaddress       => "11.10.10.1",
           :kind            => "private",
           :network_adapter =>
                               {:inventory_collection_name => :network_adapters,
                                :reference                 => {:source_ref => "interface_1"},
                                :ref                       => :manager_ref},
           :source_region   =>
                               {:inventory_collection_name => :source_regions,
                                :reference                 => {:source_ref => "useast20"},
                                :ref                       => :manager_ref},
           :subnet          =>
                               {:inventory_collection_name => :subnets,
                                :reference                 => {:source_ref => "subnet_id_1"},
                                :ref                       => :manager_ref},
           :subscription    =>
                               {:inventory_collection_name => :subscriptions,
                                :reference                 => {:source_ref => "subscription1"},
                                :ref                       => :manager_ref}},
          {:extra           =>
                               {:name                       => "floating_ip_name_1",
                                :provisioning_state         => nil,
                                :public_ipaddress_version   => nil,
                                :public_ipallocation_method => nil,
                                :resource_guid              => nil,
                                :type                       => nil,
                                :idle_timeout_in_minutes    => nil},
           :ipaddress       => "10.10.10.3",
           :kind            => "elastic",
           :network_adapter =>
                               {:inventory_collection_name => :network_adapters,
                                :reference                 =>
                                                              {:source_ref =>
                                                                              "/subscriptions/guid/resourceGroups/resource_group_name/providers/Microsoft.Network/networkInterfaces/vm1nic1"},
                                :ref                       => :manager_ref},
           :source_ref      => "floating_ip_id_1",
           :source_region   =>
                               {:inventory_collection_name => :source_regions,
                                :reference                 => {:source_ref => "useast20"},
                                :ref                       => :manager_ref},
           :subscription    =>
                               {:inventory_collection_name => :subscriptions,
                                :reference                 => {:source_ref => "subscription1"},
                                :ref                       => :manager_ref}}
        ]
      )
    )

    expect(format_hash(:ipaddress_tags, parser)).to(
      match_array(
        [
          {:ipaddress =>
                         {:inventory_collection_name => :ipaddresses,
                          :reference                 => {:source_ref => "floating_ip_id_1"},
                          :ref                       => :manager_ref},
           :tag       =>
                         {:inventory_collection_name => :tags,
                          :reference                 => {:name => :env, :value => "prod", :namespace => "azure"},
                          :ref                       => :manager_ref}},
          {:ipaddress =>
                         {:inventory_collection_name => :ipaddresses,
                          :reference                 => {:source_ref => "floating_ip_id_1"},
                          :ref                       => :manager_ref},
           :tag       =>
                         {:inventory_collection_name => :tags,
                          :reference                 => {:name => :owner, :value => "CEO", :namespace => "azure"},
                          :ref                       => :manager_ref}}
        ]
      )
    )
  end

  it "collects and parses security_groups" do
    parser = collect_and_parse(:security_groups)

    expect(format_hash(:security_groups, parser)).to(
      match_array(
        [
          {:extra         => {:provisioning_state => "Succeeded"},
           :name          => "security_group_name_1",
           :source_ref    => "security_group_id_1",
           :source_region =>
                             {:inventory_collection_name => :source_regions,
                              :reference                 => {:source_ref => "useast20"},
                              :ref                       => :manager_ref},
           :subscription  =>
                             {:inventory_collection_name => :subscriptions,
                              :reference                 => {:source_ref => "subscription1"},
                              :ref                       => :manager_ref}}
        ]
      )
    )

    expect(format_hash(:security_group_tags, parser)).to(
      match_array(
        [
          {:security_group =>
                              {:inventory_collection_name => :security_groups,
                               :reference                 => {:source_ref => "security_group_id_1"},
                               :ref                       => :manager_ref},
           :tag            =>
                              {:inventory_collection_name => :tags,
                               :reference                 => {:name => :dimension, :value => "42", :namespace => "azure"},
                               :ref                       => :manager_ref}}
        ]
      )
    )
  end

  def collect_and_parse(entity)
    parser  = TopologicalInventory::Azure::Parser.new
    metrics = instance_double(TopologicalInventory::Azure::Collector::ApplicationMetrics,
                              :record_error => nil)

    collector = TopologicalInventory::Azure::Collector.new(
      "source", "access_key_id", "secret_access_key", "tenant_id", metrics
    )
    allow(collector).to receive(:save_inventory).and_return(1)
    allow(collector).to receive(:sweep_inventory)
    allow(collector).to receive(:create_parser).and_return(parser)
    mock_collector_methods(collector)

    collector.send(:process_entity, entity)
    parser
  end

  def format_hash(entity, parser, ignore: nil)
    hash = parser.collections[entity].data.map(&:to_hash)
    if ignore
      hash = hash.map { |x| x.except(*ignore) }
    end
    hash
  end

  def mock_collector_methods(collector)
    allow(collector).to receive(:vms).and_return(mocked_vms)
    allow(collector).to receive(:flavors).and_return(mocked_flavors)
    allow(collector).to receive(:volumes).and_return(mocked_volumes)
    allow(collector).to receive(:source_regions).and_return(mocked_source_regions)
    allow(collector).to receive(:networks).and_return(mocked_networks)
    allow(collector).to receive(:network_adapters).and_return(mocked_network_adapters)
    allow(collector).to receive(:floating_ips).and_return(mocked_floating_ips)
    allow(collector).to receive(:security_groups).and_return(mocked_security_groups)
    allow(collector).to receive(:all_subscriptions_connection).and_return(mocked_all_subscriptions_connection)
  end
end
