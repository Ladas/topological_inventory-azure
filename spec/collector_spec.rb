require "topological_inventory/azure/collector/application_metrics"
require 'aws-sdk'
require 'aws-sdk-cloudformation'
require 'aws-sdk-servicecatalog'
require 'aws-sdk-pricing'
require_relative 'azure_stubs'

RSpec.describe TopologicalInventory::Azure::Collector do
  include Azure

  it "collects and parses vms" do
    parser = collect_and_parse(:vms)

    expect(format_hash(:vms, parser)).to(
      match_array(
        [{:source_ref    => "instance_0",
          :uid_ems       => "instance_0",
          :name          => "instance_0",
          :power_state   => "on",
          :mac_addresses => ["06:d5:e7:4e:c8:01"],
          :flavor        =>
            {:inventory_collection_name => :flavors,
             :reference                 => {:source_ref => "m3.medium"},
             :ref                       => :manager_ref}},
         {:source_ref    => "instance_ec2_0",
          :uid_ems       => "instance_ec2_0",
          :name          => "instance_ec2_0",
          :power_state   => "on",
          :mac_addresses => [],
          :flavor        =>
            {:inventory_collection_name => :flavors,
             :reference                 => {:source_ref => "m3.medium"},
             :ref                       => :manager_ref}},
         {:source_ref    => "instance_0",
          :uid_ems       => "instance_0",
          :name          => "instance_0",
          :power_state   => "on",
          :mac_addresses => ["06:d5:e7:4e:c8:01"],
          :flavor        =>
            {:inventory_collection_name => :flavors,
             :reference                 => {:source_ref => "m3.medium"},
             :ref                       => :manager_ref}},
         {:source_ref    => "instance_ec2_0",
          :uid_ems       => "instance_ec2_0",
          :name          => "instance_ec2_0",
          :power_state   => "on",
          :mac_addresses => [],
          :flavor        =>
            {:inventory_collection_name => :flavors,
             :reference                 => {:source_ref => "m3.medium"},
             :ref                       => :manager_ref}}]
      )
    )
  end

  it "collects and parses volumes" do
    parser = collect_and_parse(:volumes)

    expect(format_hash(:volumes, parser)).to(
      match_array(
        [{:source_ref        => "volume_id_0",
          :name              => "volume_0",
          :state             => "in-use",
          :size              => 1_073_741_824,
          :source_created_at => Time.parse("2019-02-20 09:53:48 UTC").utc,
          :volume_type       =>
                                {:inventory_collection_name => :volume_types,
                                 :reference                 => {:source_ref => "standard"},
                                 :ref                       => :manager_ref},
          :source_region     =>
                                {:inventory_collection_name => :source_regions,
                                 :reference                 => {:source_ref => "us-east-1"},
                                 :ref                       => :manager_ref}},
         {:source_ref        => "volume_id_0",
          :name              => "volume_0",
          :state             => "in-use",
          :size              => 1_073_741_824,
          :source_created_at => Time.parse("2019-02-20 09:53:48 UTC").utc,
          :volume_type       =>
                                {:inventory_collection_name => :volume_types,
                                 :reference                 => {:source_ref => "standard"},
                                 :ref                       => :manager_ref},
          :source_region     =>
                                {:inventory_collection_name => :source_regions,
                                 :reference                 => {:source_ref => "us-west-1"},
                                 :ref                       => :manager_ref}}]
      )
    )
  end

  it "collects and parses source_regions" do
    parser = collect_and_parse(:source_regions)

    expect(format_hash(:source_regions, parser)).to(
      match_array(
        [{:source_ref => "us-east-1", :name => "us-east-1"},
         {:source_ref => "us-west-1", :name => "us-west-1"}]
      )
    )
  end

  it "collects and parses service_offerings" do
    parser = collect_and_parse(:service_offerings)

    expect(format_hash(:service_offerings, parser)).to(
      match_array(
        [
          {
            :extra             => {
              :product_view_summary => {:name=>"name_0", :product_id=>"prod_0"},
              :status               => "",
              :product_arn          => "arn_0",
            },
            :source_ref        => "prod_0",
            :name              => "name_0",
            :source_created_at => Time.parse("2016-08-10 14:42:09 UTC").utc,
            :source_region     => {
              :inventory_collection_name => :source_regions,
              :reference                 => {:source_ref => "us-east-1"},
              :ref                       => :manager_ref
            }
          },
          {
            :extra             => {
              :product_view_summary => {:name=>"name_0", :product_id=>"prod_0"},
              :status               => "",
              :product_arn          => "arn_0",
            },
            :source_ref        => "prod_0",
            :name              => "name_0",
            :source_created_at => Time.parse("2016-08-10 14:42:09 UTC").utc,
            :source_region     => {
              :inventory_collection_name => :source_regions,
              :reference                 => {:source_ref => "us-west-1"},
              :ref                       => :manager_ref
            }
          }
        ]
      )
    )
  end

  it "collects and parses service_instances" do
    parser = collect_and_parse(:service_instances)

    expect(format_hash(:service_instances, parser, :ignore => [:extra])).to(
      match_array(
        [
          {
            :service_offering  =>
              {:inventory_collection_name => :service_offerings,
               :reference                 => {:source_ref => "prod_1"},
               :ref                       => :manager_ref},
            :service_plan      =>
              {:inventory_collection_name => :service_plans,
               :reference                 => {:source_ref => "prod_1__provisioning_artifact_1__path_1"},
               :ref                       => :manager_ref},
            :source_created_at => Time.parse("2016-08-10 16:42:01 +0200").utc,
            :source_ref        => "id_0",
            :source_region     =>
              {:inventory_collection_name => :source_regions,
               :reference                 => {:source_ref => "us-east-1"},
               :ref                       => :manager_ref}},
          {:service_offering  =>
             {:inventory_collection_name => :service_offerings,
              :reference                 => {:source_ref => "prod_1"},
              :ref                       => :manager_ref},
           :service_plan      =>
             {:inventory_collection_name => :service_plans,
              :reference                 => {:source_ref => "prod_1__provisioning_artifact_1__path_1"},
              :ref                       => :manager_ref},
           :source_created_at => Time.parse("2016-08-10 16:42:01 +0200").utc,
           :source_ref        => "id_0",
           :source_region     =>
             {:inventory_collection_name => :source_regions,
              :reference                 => {:source_ref => "us-west-1"},
              :ref                       => :manager_ref}}]
      )
    )
  end

  it "collects and parses service_plans" do
    parser = collect_and_parse(:service_plans)

    expect(format_hash(:service_plans, parser, :ignore => [:extra])).to(
      match_array(
        [
          {
            :name             => "name_0 provisioning_artifact_1_name path_1_name",
            :service_offering =>
              {:inventory_collection_name => :service_offerings,
               :reference                 => {:source_ref => "prod_0"},
               :ref                       => :manager_ref},
            :source_ref       => "prod_0__provisioning_artifact_1__path_1",
            :source_region    =>
              {:inventory_collection_name => :source_regions,
               :reference                 => {:source_ref => "us-east-1"},
               :ref                       => :manager_ref}},
          {
            :name             => "name_0 provisioning_artifact_1_name path_1_name",
            :service_offering =>
              {:inventory_collection_name => :service_offerings,
               :reference                 => {:source_ref => "prod_0"},
               :ref                       => :manager_ref},
            :source_ref       => "prod_0__provisioning_artifact_1__path_1",
            :source_region    =>
              {:inventory_collection_name => :source_regions,
               :reference                 => {:source_ref => "us-west-1"},
               :ref                       => :manager_ref}}]
      )
    )
  end

  it "collects and parses flavors" do
    parser = collect_and_parse(:flavors)

    expect(format_hash(:flavors, parser)).to(
      match_array(
        [{:source_ref => "m5d.12xlarge",
          :name       => "m5d.12xlarge",
          :disk_size  => 966_367_641_600,
          :disk_count => "2",
          :memory     => 206_158_430_208,
          :cpus       => 48,
          :extra      => {
            :attributes => {
              :dedicatedEbsThroughput => "6000 Mbps",
              :physicalProcessor      => "Intel Xeon Platinum 8175",
              :clockSpeed             => "2.5 GHz",
              :ecu                    => "173",
              :networkPerformance     => "10 Gigabit",
              :processorFeatures      => "Intel AVX, Intel AVX2, Intel AVX512, Intel Turbo"
            },
            :prices     => {
              :OnDemand => {
                "22PCVUMSTSHECWJD.JRTCKXETXF" => {
                  "sku"             => "22PCVUMSTSHECWJD",
                  "effectiveDate"   => "2018-12-01T00:00:00Z",
                  "offerTermCode"   => "JRTCKXETXF",
                  "termAttributes"  => {},
                  "priceDimensions" => {
                    "22PCVUMSTSHECWJD.JRTCKXETXF.6YS6EN2CT7" => {
                      "unit"         => "Hrs",
                      "endRange"     => "Inf",
                      "rateCode"     => "22PCVUMSTSHECWJD.JRTCKXETXF.6YS6EN2CT7",
                      "appliesTo"    => [],
                      "beginRange"   => "0",
                      "description"  => "$2.712 per On Demand Linux m5d.12xlarge Instance Hour",
                      "pricePerUnit" => {"USD" => "2.7120000000"}
                    }
                  }
                }
              }
            }
          }},
         {:source_ref => "t1.micro",
          :name       => "t1.micro",
          :disk_size  => 0,
          :disk_count => 0,
          :memory     => 2_064_805_527_552,
          :cpus       => 2,
          :extra      =>
                         {:attributes =>
                                         {:dedicatedEbsThroughput => "6000 Mbps",
                                          :physicalProcessor      => "Intel Xeon Platinum 8175",
                                          :clockSpeed             => "2.5 GHz",
                                          :ecu                    => "173",
                                          :networkPerformance     => "10 Gigabit",
                                          :processorFeatures      => "Intel AVX, Intel AVX2, Intel AVX512, Intel Turbo"},
                          :prices     => {:OnDemand => nil}}}]
      )
    )
  end

  it "collects and parses volume_types" do
    parser = collect_and_parse(:volume_types)

    expect(format_hash(:volume_types, parser)).to(
      match_array(
        [{:source_ref  => "standard",
          :name        => "standard",
          :description => "Magnetic",
          :extra       =>
                          {:storageMedia  => "HDD-backed",
                           :volumeType    => "Magnetic",
                           :maxIopsvolume => "40 - 200",
                           :maxVolumeSize => "1 TiB"}},
         {:source_ref  => "gp2",
          :name        => "gp2",
          :description => "General Purpose",
          :extra       =>
                          {:storageMedia  => "SSD-backed",
                           :volumeType    => "General Purpose",
                           :maxIopsvolume => "16000",
                           :maxVolumeSize => "16 TiB"}}]
      )
    )
  end

  def collect_and_parse(entity)
    parser = TopologicalInventory::Azure::Parser.new
    metrics = instance_double(TopologicalInventory::Azure::Collector::ApplicationMetrics,
                              :record_error => nil)

    collector = TopologicalInventory::Azure::Collector.new(
      "source", "access_key_id", "secret_access_key", metrics)
    allow(collector).to receive(:save_inventory).and_return(1)
    allow(collector).to receive(:sweep_inventory)
    allow(collector).to receive(:create_parser).and_return(parser)

    with_aws_stubbed(stub_responses) do
      collector.send(:process_entity, entity)
    end
    parser
  end

  def format_hash(entity, parser, ignore: nil)
    hash = parser.collections[entity].data.map(&:to_hash)
    if ignore
      hash = hash.map { |x| x.except(*ignore) }
    end
    hash
  end

  def with_aws_stubbed(stub_responses_per_service)
    stub_responses_per_service.each do |service, stub_responses|
      raise "Aws.config[#{service}][:stub_responses] already set" if Aws.config.fetch(service, {})[:stub_responses]

      Aws.config[service] ||= {}
      Aws.config[service][:stub_responses] = stub_responses
    end
    yield
  ensure
    stub_responses_per_service.keys.each do |service|
      Aws.config[service].delete(:stub_responses)
    end
  end

  def stub_responses
    {
      :ec2            => {
        :describe_regions            => mocked_regions,
        :describe_availability_zones => mocked_availability_zones,
        :describe_instances          => mocked_instances,
        :describe_key_pairs          => mocked_key_pairs,
        :describe_images             => mocked_images,
        :describe_vpcs               => mocked_vpcs,
        :describe_subnets            => mocked_subnets,
        :describe_security_groups    => mocked_security_groups,
        :describe_network_interfaces => mocked_network_ports,
        :describe_addresses          => mocked_floating_ips,
        :describe_volumes            => mocked_cloud_volumes,
        :describe_snapshots          => mocked_cloud_volume_snapshots,
      },
      :cloudformation => {
        :describe_stacks      => mocked_stacks,
        :list_stack_resources => mocked_stack_resources
      },
      :servicecatalog => {
        :search_products_as_admin  => mocked_products,
        :scan_provisioned_products => mocked_provisioned_products,
        :describe_record           => mocked_describe_record,
        :describe_product          => mocked_describe_product,
        :list_launch_paths         => mocked_list_launch_paths,
      },
      :pricing        => {
        :get_products => mocked_pricing_products,
      }
    }
  end
end
