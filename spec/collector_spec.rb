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
           :mac_addresses => [],
           :name          => "Instance Name 1",
           :power_state   => "powering_down",
           :source_ref    => "instanceid1",
           :uid_ems       => "instanceid1"}
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
           :size              => 100 * 1024**3,
           :source_created_at => "2019-10-10 20:42",
           :source_ref        => "volumeid1",
           :source_region     =>
                                 {:inventory_collection_name => :source_regions,
                                  :reference                 => {:source_ref => "useast20"},
                                  :ref                       => :manager_ref},
           :state             => "Succeeded"}
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
    allow(collector).to receive(:all_subscriptions_connection).and_return(mocked_all_subscriptions_connection)
  end
end
