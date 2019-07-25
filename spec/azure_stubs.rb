module AwsStubs
  def scaling_factor
    1
  end

  def test_counts(scaling = nil)
    scaling ||= scaling_factor
    {
      :load_balancer_count                             => scaling * 1,
      :availability_zone_count                         => scaling * 1,
      :instance_vpc_count                              => scaling * 1,
      :instance_ec2_count                              => scaling * 1,
      :image_count                                     => scaling * 1,
      :key_pair_count                                  => scaling * 1,
      :stack_count                                     => scaling * 1,
      :stack_resource_count                            => scaling * 1,
      :stack_parameter_count                           => scaling * 1,
      :stack_output_count                              => scaling * 1,
      :load_balancer_instances_count                   => scaling * 1,
      :load_balancer_pool_member                       => scaling * 1,
      :vpc_count                                       => scaling * 1,
      :subnet_count                                    => scaling * 1,
      :network_port_count                              => scaling * 1,
      :floating_ip_count                               => scaling * 1,
      :security_group_count                            => scaling * 1,
      :inbound_firewall_rule_per_security_group_count  => scaling * 1,
      :outbound_firewall_rule_per_security_group_count => scaling * 1,
      :cloud_volume_count                              => scaling * 1,
      :cloud_volume_snapshot_count                     => scaling * 1,
      :s3_buckets_count                                => scaling * 1,
      :s3_objects_per_bucket_count                     => scaling * 1,
      :products                                        => scaling * 1,
      :provisioned_products                            => scaling * 1,
    }
  end

  def mocked_floating_ips
    floating_ips = []
    test_counts[:floating_ip_count].times do |i|
      floating_ips << {
        :instance_id   => "instance_#{i}",
        :allocation_id => "allocation_#{i}",
        :public_ip     => "54.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
        :domain        => "vpc"
      }
    end
    {:addresses => floating_ips}
  end

  def mocked_products
    products = []

    test_counts[:products].times do |i|
      products << {
        :product_view_summary => {
          :product_id => "prod_#{i}",
          :name       => "name_#{i}",
        },
        :status               => "",
        :product_arn          => "arn_#{i}",
        :created_time         => Time.parse("2016-08-10 14:42:09 UTC").utc
      }
    end

    {:product_view_details => products}
  end

  def mocked_provisioned_products
    provisioned_products = []
    test_counts[:provisioned_products].times do |i|
      provisioned_products << {
        :id                => "id_#{i}",
        :arn               => "arn_#{i}",
        :type              => "type_#{i}",
        :status            => "status",
        :status_message    => "status_message",
        :idempotency_token => "idempotency_token",
        :last_record_id    => "last_record_id",
        :created_time      => Time.parse("2016-08-10 14:42:01 UTC").utc
      }
    end

    {:provisioned_products => provisioned_products}
  end

  def mocked_describe_record
    {
      :record_detail => {
        :product_id               => "prod_1",
        :path_id                  => "path_1",
        :provisioning_artifact_id => "provisioning_artifact_1"
      }
    }
  end

  def mocked_describe_product
    {
      :provisioning_artifacts => [
        {
          :id   => "provisioning_artifact_1",
          :name => "provisioning_artifact_1_name",
        }
      ]
    }
  end

  def mocked_list_launch_paths
    {
      :launch_path_summaries => [
        {
          :id   => "path_1",
          :name => "path_1_name",
        }
      ]
    }
  end

  def mocked_pricing_products
    {
      :price_list => [
        {
          :product => {
            :attributes => {
              "instanceType"           => "m5d.12xlarge",
              "ecu"                    => "173",
              "vcpu"                   => "48",
              "memory"                 => "192 GiB",
              "storage"                => "2 x 900 NVMe SSD",
              "clockSpeed"             => "2.5 GHz",
              "physicalProcessor"      => "Intel Xeon Platinum 8175",
              "processorFeatures"      => "Intel AVX, Intel AVX2, Intel AVX512, Intel Turbo",
              "networkPerformance"     => "10 Gigabit",
              "dedicatedEbsThroughput" => "6000 Mbps"
            }
          },
          "terms"  => {
            "OnDemand" => {
              "22PCVUMSTSHECWJD.JRTCKXETXF" => {
                "sku"             => "22PCVUMSTSHECWJD",
                "effectiveDate"   => "2018-12-01T00:00:00Z",
                "offerTermCode"   => "JRTCKXETXF",
                "termAttributes"  => {},
                "priceDimensions" =>
                                     {
                                       "22PCVUMSTSHECWJD.JRTCKXETXF.6YS6EN2CT7" => {
                                         "unit"         => "Hrs",
                                         "endRange"     => "Inf",
                                         "rateCode"     => "22PCVUMSTSHECWJD.JRTCKXETXF.6YS6EN2CT7",
                                         "appliesTo"    => [],
                                         "beginRange"   => "0",
                                         "description"  => "$2.712 per On Demand Linux m5d.12xlarge Instance Hour",
                                         "pricePerUnit" => {
                                           "USD" => "2.7120000000"
                                         }
                                       }
                                     }
              }
            }
          }
        }.to_json, {
          :product => {
            :attributes => {
              "instanceType"           => "t1.micro",
              "vcpu"                   => "2",
              "ecu"                    => "173",
              "memory"                 => "192,3 GiB",
              "storage"                => "900 NVMe SSD",
              "clockSpeed"             => "2.5 GHz",
              "physicalProcessor"      => "Intel Xeon Platinum 8175",
              "processorFeatures"      => "Intel AVX, Intel AVX2, Intel AVX512, Intel Turbo",
              "networkPerformance"     => "10 Gigabit",
              "dedicatedEbsThroughput" => "6000 Mbps"
            }
          }
        }.to_json, {
          "product"         =>
                               {
                                 "productFamily" => "Storage",
                                 "attributes"    => {
                                   "storageMedia"            => "HDD-backed",
                                   "maxThroughputvolume"     => "40 - 90 MB/sec",
                                   "volumeType"              => "Magnetic",
                                   "maxIopsvolume"           => "40 - 200",
                                   "servicecode"             => "AzureEC2",
                                   "usagetype"               => "EBS:VolumeUsage",
                                   "locationType"            => "AWS Region",
                                   "location"                => "US East (N. Virginia)",
                                   "servicename"             => "Azure Elastic Compute Cloud",
                                   "maxVolumeSize"           => "1 TiB",
                                   "operation"               => "",
                                   "maxIopsBurstPerformance" => "Hundreds"
                                 },
                                 "sku"           => "269VXUCZZ7E6JNXT"
                               },
          "serviceCode"     => "AzureEC2",
          "terms"           => {
            "OnDemand" => {
              "269VXUCZZ7E6JNXT.JRTCKXETXF" => {
                "priceDimensions" => {
                  "269VXUCZZ7E6JNXT.JRTCKXETXF.6YS6EN2CT7" => {
                    "unit"         => "GB-Mo",
                    "endRange"     => "Inf",
                    "description"  =>
                                      "$0.05 per GB-month of Magnetic provisioned storage - US East (Northern Virginia)",
                    "appliesTo"    => [],
                    "rateCode"     => "269VXUCZZ7E6JNXT.JRTCKXETXF.6YS6EN2CT7",
                    "beginRange"   => "0",
                    "pricePerUnit" => {
                      "USD" => "0.0500000000"
                    }
                  }
                },
                "sku"             => "269VXUCZZ7E6JNXT",
                "effectiveDate"   => "2019-02-01T00:00:00Z",
                "offerTermCode"   => "JRTCKXETXF",
                "termAttributes"  => {}
              }
            }
          },
          "version"         => "20190215225445",
          "publicationDate" => "2019-02-15T22:54:45Z"
        }.to_json, {
          "product"         => {
            "productFamily" => "Storage",
            "attributes"    => {
              "storageMedia"            => "SSD-backed",
              "maxThroughputvolume"     => "250 MiB/s",
              "volumeType"              => "General Purpose",
              "maxIopsvolume"           => "16000",
              "servicecode"             => "AzureEC2",
              "usagetype"               => "EBS:VolumeUsage.gp2",
              "locationType"            => "AWS Region",
              "location"                => "US East (N. Virginia)",
              "servicename"             => "Azure Elastic Compute Cloud",
              "maxVolumeSize"           => "16 TiB",
              "operation"               => "",
              "maxIopsBurstPerformance" => "3000 for volumes <= 1 TiB"
            },
            "sku"           => "HY3BZPP2B6K8MSJF"
          },
          "serviceCode"     => "AzureEC2",
          "terms"           => {
            "OnDemand" => {
              "HY3BZPP2B6K8MSJF.JRTCKXETXF" => {
                "priceDimensions" => {
                  "HY3BZPP2B6K8MSJF.JRTCKXETXF.6YS6EN2CT7" => {
                    "unit"         => "GB-Mo",
                    "endRange"     => "Inf",
                    "description"  =>
                                      "$0.10 per GB-month of General Purpose SSD (gp2) provisioned storage - US East (Northern Virginia)",
                    "appliesTo"    => [],
                    "rateCode"     => "HY3BZPP2B6K8MSJF.JRTCKXETXF.6YS6EN2CT7",
                    "beginRange"   => "0",
                    "pricePerUnit" => {
                      "USD" => "0.1000000000"
                    }
                  }
                },
                "sku"             => "HY3BZPP2B6K8MSJF",
                "effectiveDate"   => "2019-02-01T00:00:00Z",
                "offerTermCode"   => "JRTCKXETXF",
                "termAttributes"  => {}
              }
            }
          },
          "version"         => "20190215225445",
          "publicationDate" => "2019-02-15T22:54:45Z"
        }.to_json
      ]
    }
  end

  def mocked_network_ports
    ports = []
    test_counts[:network_port_count].times do |i|
      ports << {
        :vpc_id               => "vpc_#{i}",
        :subnet_id            => "subnet_#{i}",
        :network_interface_id => "network_interface_#{i}",
        :attachment           => {:instance_id => "instance_#{i}"},
        :private_ip_addresses => [
          {
            :private_ip_address => "10.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
            :primary            => true,
            :association        => {
              :public_ip     => "58.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
              :allocation_id => nil
            }
          }, {
            :private_ip_address => "11.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
          }
        ]
      }
    end

    {:network_interfaces => ports}
  end

  def mocked_security_groups
    mocked_security_groups = []

    test_counts[:security_group_count].times do |i|
      inbound_firewall_rules = []
      test_counts[:inbound_firewall_rule_per_security_group_count].times do |fi|
        inbound_firewall_rules << {
          :ip_protocol         => "TCP",
          :from_port           => 0,
          :to_port             => fi,
          :user_id_group_pairs => [
            {
              :vpc_id => "vpc_#{i}"
            }
          ]
        }
      end

      outbound_firewall_rules = []
      test_counts[:outbound_firewall_rule_per_security_group_count].times do |fi|
        outbound_firewall_rules << {
          :ip_protocol => "TCP",
          :from_port   => 0,
          :to_port     => fi,
          :ip_ranges   => [
            {
              :cidr_ip => "0.0.0.0/0"
            }
          ]
        }
      end

      mocked_security_groups << {
        :group_id              => "security_group_#{i}",
        :vpc_id                => "vpc_#{i}",
        :ip_permissions        => inbound_firewall_rules,
        :ip_permissions_egress => outbound_firewall_rules
      }
    end
    {:security_groups => mocked_security_groups}
  end

  def mocked_instances
    instances = []
    test_counts[:instance_vpc_count].times do |i|
      instances << {
        :instance_id        => "instance_#{i}",
        :instance_type      => 'm3.medium',
        :image_id           => "image_id_#{i}",
        :private_ip_address => "10.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
        :public_ip_address  => "40.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
        :state              => {:name => 'running'},
        :architecture       => 'x86_64',
        :placement          => {:availability_zone => "us-east-1e"},
        :tags               => [
          {
            :key   => "tag_01_for_instance_#{i % 1000}",
            :value => "tag_01_value_for_instance_#{i % 1000}"
          }, {
            :key   => "tag_02_for_instance_#{i % 1000}",
            :value => "tag_02_value_for_instance_#{i % 1000}"
          }, {
            :key   => "tag_03_for_instance_#{i % 1000}",
            :value => "tag_03_value_for_instance_#{i % 1000}"
          }
        ],
        :network_interfaces => [
          {
            :network_interface_id => "interface_#{i}",
            :mac_address          => "06:d5:e7:4e:c8:01",
          }
        ]
      }
    end

    test_counts[:instance_ec2_count].times.each do |i|
      instances << {
        :instance_id        => "instance_ec2_#{i}",
        :instance_type      => 'm3.medium',
        :image_id           => "image_id_#{i}",
        :private_ip_address => "11.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
        :public_ip_address  => "41.#{(i / 255) == 0 ? 0 : i % (i / 255)}.#{i / 255}.#{i % 255}",
        :state              => {:name => 'running'},
        :architecture       => 'x86_64',
        :placement          => {:availability_zone => "us-east-1e"},
        :tags               => [
          {
            :key   => "tag_01_for_instance_#{i % 1000}",
            :value => "tag_01_value_for_instance_#{i % 1000}"
          }, {
            :key   => "tag_02_for_instance_#{i % 1000}",
            :value => "tag_02_value_for_instance_#{i % 1000}"
          }, {
            :key   => "tag_03_for_instance_#{i % 1000}",
            :value => "tag_03_value_for_instance_#{i % 1000}"
          }
        ]
      }
    end

    {:reservations => [{:instances => instances}]}
  end

  def mocked_images
    mocked_images = []
    test_counts[:image_count].times do |i|
      mocked_images << {
        :image_id       => "image_id_#{i}",
        :image_location => "image_location_#{i}",
        :kernel_id      => "aki_#{i}",
        :ramdisk_id     => "ari_#{i}",
        :architecture   => 'x86_64',
        :state          => "available",
        :tags           => [
          {
            :key   => "tag_01_for_image_#{i % 1000}",
            :value => "tag_01_value_for_image_#{i % 1000}"
          }, {
            :key   => "tag_02_for_image_#{i % 1000}",
            :value => "tag_02_value_for_image_#{i % 1000}"
          }, {
            :key   => "tag_03_for_image_#{i % 1000}",
            :value => "tag_03_value_for_image_#{i % 1000}"
          }
        ],
      }
    end

    {:images => mocked_images}
  end

  def mocked_key_pairs
    mocked_key_pairs = []
    test_counts[:key_pair_count].times do |i|
      mocked_key_pairs << {
        :key_name        => "key_pair_#{i}",
        :key_fingerprint => "66:e9:a2:2a:7f:6d:89:b2:71:3f:1y:eb:a8:95:9f:c3:f6:ce:c7:56"
      }
    end

    {:key_pairs => mocked_key_pairs}
  end

  def mocked_stacks
    mocked_stacks = []
    test_counts[:stack_count].times do |i|
      mocked_stacks << {
        :stack_name    => "stack_name_#{i}",
        :stack_id      => "stack_id_#{i}",
        :description   => "stack_dec_#{i}",
        :stack_status  => 'CREATE_COMPLETE',
        :creation_time => Time.now.utc,
        :parameters    => mocked_stack_parameters,
        :outputs       => mocked_stack_outputs
      }
    end

    {:stacks => mocked_stacks}
  end

  def mocked_stack_resources
    mocked_stack_resources = []
    test_counts[:stack_count].times do |stack_index|
      stack_resources = []
      test_counts[:stack_resource_count].times do |i|
        stack_resources << {
          :physical_resource_id   => ":stack/stack_name_#{stack_index}-stack_id_#{stack_index}/stack_physical_resource_id_#{i}",
          :logical_resource_id    => "logical_resource_id_#{i}",
          :resource_type          => "AWS::EC2::InternetGateway",
          :last_updated_timestamp => Time.now.utc,
          :resource_status        => 'CREATE_COMPLETE'
        }
      end
      mocked_stack_resources << {:stack_resource_summaries => stack_resources}
    end

    mocked_stack_resources
  end

  def mocked_stack_parameters
    mocked_stack_parameters = []
    test_counts[:stack_parameter_count].times do |i|
      mocked_stack_parameters << {
        :parameter_key   => "stack_parameter_key#{i}",
        :parameter_value => "stack_parameter_value_#{i}"
      }
    end

    mocked_stack_parameters
  end

  def mocked_stack_outputs
    mocked_stack_outputs = []
    test_counts[:stack_output_count].times do |i|
      mocked_stack_outputs << {
        :output_key   => "stack_output_key#{i}",
        :output_value => "stack_output_value_#{i}"
      }
    end

    mocked_stack_outputs
  end

  def mocked_regions
    {
      :regions => [
        {:region_name => 'us-east-1'},
        {:region_name => 'us-west-1'},
      ]
    }
  end

  def mocked_availability_zones
    {:availability_zones => [
      {:zone_name => "us-east-1a", :region_name => "us-east-1", :state => "available"},
      {:zone_name => "us-east-1b", :region_name => "us-east-1", :state => "available"},
      {:zone_name => "us-east-1c", :region_name => "us-east-1", :state => "available"},
      {:zone_name => "us-east-1d", :region_name => "us-east-1", :state => "available"},
      {:zone_name => "us-east-1e", :region_name => "us-east-1", :state => "available"}
    ]}
  end

  def mocked_vpcs
    mocked_vpcs = []
    test_counts[:vpc_count].times do |i|
      mocked_vpcs << {
        :vpc_id => "vpc_#{i}"
      }
    end

    {:vpcs => mocked_vpcs}
  end

  def mocked_subnets
    mocked_subnets = []
    test_counts[:subnet_count].times do |i|
      mocked_subnets << {
        :vpc_id    => "vpc_#{i}",
        :subnet_id => "subnet_#{i}"
      }
    end

    {:subnets => mocked_subnets}
  end

  def mocked_load_balancers
    mocked_lbs = []
    test_counts[:load_balancer].times do |i|
      instances = []
      test_counts[:load_balancer_instances_count].times do |ins|
        instance             = OpenStruct.new
        instance.instance_id = "instance_#{ins}"
        instances << instance.to_h
      end

      health_check                     = OpenStruct.new
      health_check.target              = "TCP:22"
      health_check.interval            = 30
      health_check.timeout             = 5
      health_check.unhealthy_threshold = 2
      health_check.healthy_threshold   = 10

      listener                    = OpenStruct.new
      listener.protocol           = "TCP"
      listener.load_balancer_port = 2222
      listener.instance_protocol  = "TCP"
      listener.instance_port      = 22
      listener.ssl_certificate_id = nil

      listener_desc              = OpenStruct.new
      listener_desc.listener     = listener.to_h
      listener_desc.policy_names = []

      source_security_group             = OpenStruct.new
      source_security_group.owner_alias = "200278856672"
      source_security_group.group_name  = "quick-create-1"

      lb                               = OpenStruct.new
      lb.load_balancer_name            = "EmSRefreshSpecVPC#{i}"
      lb.dns_name                      = "EmSRefreshSpecVPCELB#{i}-1206960929.us-east-1.elb.azureaws.com"
      lb.canonical_hosted_zone_name    = "EmSRefreshSpecVPCELB#{i}-1206960929.us-east-1.elb.azureaws.com"
      lb.canonical_hosted_zone_name_id = "Z35SXDOTRQ7X7#{i}"
      lb.listener_descriptions         = [listener_desc.to_h]
      lb.policies                      = {}
      lb.backend_server_descriptions   = []
      lb.availability_zones            = ["us-east-1d", "us-east-1e"]
      lb.subnets                       = ["subnet_1", "subnet_2"]
      lb.vpc_id                        = "vpc-ff49ff91"
      lb.instances                     = instances
      lb.health_check                  = health_check.to_h
      lb.source_security_group         = source_security_group.to_h
      lb.security_groups               = ["sg-0d2cd677"]
      lb.created_time                  = Time.parse("2016-08-10 14:17:09 UTC").utc
      lb.scheme                        = "internet-facing"
      mocked_lbs << lb.to_h
    end
    mocked_lbs
  end

  def mocked_s3_buckets
    mocked_s3_buckets = []
    test_counts[:s3_buckets_count].times do |i|
      mocked_s3_buckets << {
        :name          => "bucket_id_#{i}",
        :creation_date => Time.now.utc
      }
    end
    mocked_s3_buckets
  end

  def mocked_s3_objects
    mocked_s3_objects = []
    test_counts[:s3_objects_per_bucket_count].times do |i|
      mocked_s3_objects << {
        :key           => "object_key_#{i}",
        :etag          => "object_key_#{i}",
        :size          => 1,
        :last_modified => Time.now.utc
      }
    end
    mocked_s3_objects
  end

  def mocked_instance_health
    mocked_instance_healths = []
    test_counts[:load_balancer_pool_member].times do |i|
      health             = OpenStruct.new
      health.instance_id = "instance_#{i}"
      health.state       = "OutOfService"
      health.reason_code = "Instance"
      health.description = "Instance has failed at least the UnhealthyThreshold number of health checks consecutively."
      mocked_instance_healths << health.to_h
    end
    mocked_instance_healths
  end

  def mocked_cloud_volumes
    mocked_cloud_volumes = []
    test_counts[:cloud_volume_count].times do |i|
      mocked_cloud_volumes << {
        :availability_zone => "us-east-1e",
        :create_time       => Time.parse("2019-02-20 09:53:48 UTC").utc,
        :size              => 1,
        :state             => "in-use",
        :volume_id         => "volume_id_#{i}",
        :volume_type       => "standard",
        :snapshot_id       => "snapshot_id_#{i}",
        :tags              => [{:key => "name", :value => "volume_#{i}"}],
        :iops              => (i == 0 ? 100 : nil),
        :encrypted         => i == 0,
      }
    end

    unless mocked_cloud_volumes.empty?
      # Attach the first cloud volume to a specific instance.
      volume_with_attachment               = mocked_cloud_volumes[0]
      volume_with_attachment[:attachments] = [
        {
          :volume_id             => "volume_id_0",
          :instance_id           => "instance_0",
          :device                => "/dev/sda1",
          :state                 => "attached",
          :attach_time           => Time.parse("2019-02-20 09:54:48 UTC").utc,
          :delete_on_termination => true
        }
      ]
    end

    {:volumes => mocked_cloud_volumes}
  end

  def mocked_cloud_volume_snapshots
    mocked_cloud_volume_snapshots = []
    test_counts[:cloud_volume_snapshot_count].times do |i|
      mocked_cloud_volume_snapshots << {
        :snapshot_id => "snapshot_id_#{i}",
        :description => "snapshot_desc_#{i}",
        :start_time  => Time.now.utc,
        :volume_size => 1,
        :state       => "completed",
        :volume_id   => "volume_id_#{i}",
        :tags        => [{:key => "name", :value => "snapshot_#{i}"}],
        :encrypted   => i == 0,
      }
    end

    {:snapshots => mocked_cloud_volume_snapshots}
  end
end
