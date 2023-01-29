# Copyright 2018-2021 Shine Solutions Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AwsMocker
  def add_instance(env, id, state_name, state_code, tags = {})
    @instances = Hash.new {} if @instances.nil?
    ec2_resource = env.ec2_resource
    @instances[id] = mock_ec2_instance(ec2_resource, id, state_name, state_code, tags)
    add_ec2_instance(ec2_resource, @instances, ec2_resource.instance_filter)
    add_elb_instances(env.elb_client, @instances) if env.elb_client
    add_asg_instances(env.asg_client, @instances) if env.asg_client
  end

  def add_metric(env, metric_name, instance_ids)
    @metrics = Hash.new {} if @metrics.nil?
    @metrics[metric_name] = mock_cloud_watch_metric(@metrics, metric_name, instance_ids)
    add_metrics(env.cloud_watch_client, @metrics, metric_name, instance_ids)
  end
end

module AwsAutoScalingMocker
  def add_asg_instances(mock_asg, instances)
    asg_instances = []
    instances.each do |id, instance|
      asg_instances.push(mock_as_instance(id, instance.state))
    end
    allow(mock_asg).to receive(:instances) { asg_instances }
  end

  def mock_asg_client(ec2_component)
    mock_as_client = double('mock_asg')
    auto_scaling_group_name = 'asg-test'.freeze
    mock_as_group = mock_as_group(auto_scaling_group_name,
                                  1,
                                  [],
                                  mock_as_tag('StackPrefix', TEST_STACK_PREFIX),
                                  mock_as_tag('Component', ec2_component))
    allow(mock_as_client).to receive(:describe_auto_scaling_groups) { mock_as_groups_type(mock_as_group) }
    # For test convenience:
    allow(mock_as_client).to receive(:as_group) { mock_as_group }
    mock_as_client
  end

  def mock_as_instance(id, status)
    as_instance = double('as_instance')
    allow(as_instance).to receive(:instance_id) { id }
    allow(as_instance).to receive(:health_status) { status }
    as_instance
  end

  def mock_as_tag(key, value)
    as_tag = double('as_tag')
    allow(as_tag).to receive(:key) { key }
    allow(as_tag).to receive(:value) { value }

    allow(as_tag).to receive(:to_s) { "#{key} : #{value}" }
    allow(as_tag).to receive(:inspect) { "#{key} : #{value}" }
    as_tag
  end

  def mock_as_group(name, desired_capacity, instances, *tags)
    as_group = double('as_group')
    allow(as_group).to receive(:auto_scaling_group_name) { name }
    allow(as_group).to receive(:desired_capacity) { desired_capacity }
    allow(as_group).to receive(:instances) { instances }
    allow(as_group).to receive(:tags) { tags }
    as_group
  end

  def mock_as_groups_type(*as_groups)
    as_groups_type = double('as_groups_type')
    allow(as_groups_type).to receive(:auto_scaling_groups) { as_groups }
    allow(as_groups_type).to receive(:next_token) { nil }
    as_groups_type
  end
end

# rubocop:disable Metrics/MethodLength
module AwsElasticLoadBalancerMocker
  def mock_elb_client(load_balancer_id, load_balancer_name, stack_prefix)
    client = Aws::ElasticLoadBalancingV2::Client.new(stub_responses: true)
    client.stub_responses(
      :describe_load_balancers,
      {
        load_balancers: [
          {
            availability_zones: [
              {
                subnet_id: 'subnet-8360a9e7',
                zone_name: 'us-west-2a'
              },
              {
                subnet_id: 'subnet-b7d581c0',
                zone_name: 'us-west-2b'
              }
            ],
            canonical_hosted_zone_id: 'Z2P70J7EXAMPLE',
            created_time: Time.parse('2016-03-25T21:26:12.920Z'),
            dns_name: 'my-load-balancer-424835706.us-west-2.elb.amazonaws.com',
            load_balancer_arn: "arn:aws:elasticloadbalancing:us-west-2:123456789012:#{load_balancer_id}/50dc6c495c0c9188",
            load_balancer_name: load_balancer_name,
            scheme: 'internet-facing',
            security_groups: [
              'sg-5943793c'
            ],
            state: {
              code: 'active'
            },
            type: 'application',
            vpc_id: 'vpc-3ac0fb5f'
          }
        ]
      }
    )
    client.stub_responses(
      :describe_tags,
      {
        tag_descriptions: [
          {
            resource_arn: "arn:aws:elasticloadbalancing:us-west-2:123456789012:#{load_balancer_id}/50dc6c495c0c9188",
            tags: [
              {
                key: 'StackPrefix',
                value: stack_prefix
              },
              {
                key: 'Name',
                value: load_balancer_name
              }
            ]
          }
        ]
      }
    )
    client.stub_responses(
      :describe_target_groups,
      {
        target_groups: [
          {
            health_check_interval_seconds: 30,
            health_check_path: '/',
            health_check_port: 'traffic-port',
            health_check_protocol: 'HTTP',
            health_check_timeout_seconds: 5,
            healthy_threshold_count: 5,
            load_balancer_arns: [
              "arn:aws:elasticloadbalancing:us-west-2:123456789012:#{load_balancer_id}/50dc6c495c0c9188"
            ],
            matcher: {
              http_code: '200'
            },
            port: 80,
            protocol: 'HTTP',
            target_group_arn: 'arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067',
            target_group_name: 'my-targets',
            unhealthy_threshold_count: 2,
            vpc_id: 'vpc-3ac0fb5f'
          }
        ]
      }
    )
    client.stub_responses(
      :describe_target_health,
      {
        target_health_descriptions: [
          {
            target: {
              id: 'i-0f76fade',
              port: 80
            },
            target_health: {
              state: 'healthy'
            }
          },
          {
            health_check_port: '80',
            target: {
              id: 'i-0f76fade',
              port: 80
            },
            target_health: {
              state: 'healthy'
            }
          }
        ]
      }
    )
    client
  end
end
# rubocop:enable Metrics/MethodLength

module AwsEc2Mocker
  def add_ec2_instance(mock_ec2, instances, instance_filter = [])
    instances.each do |id, instance|
      allow(mock_ec2).to receive(:instance).with(id) { instance }
    end
    allow(mock_ec2).to receive(:instances).with(anything) { -> { filter_instances(instances.values, instance_filter) }.call }
    allow(mock_ec2).to receive(:instances).with(no_args) { -> { filter_instances(instances.values, instance_filter) }.call }
  end

  def mock_ec2_resource(ec2_component, ec2_name)
    mock_ec2 = double('mock_ec2')

    # Store non-doubled methods for convenience in testing
    allow(mock_ec2).to receive(:ec2_component) { ec2_component }
    allow(mock_ec2).to receive(:ec2_name) { ec2_name }
    allow(mock_ec2).to receive(:instance_filter) {
      [
        { StackPrefix: TEST_STACK_PREFIX },
        { Component: ec2_component },
        { Name: ec2_name }
      ].freeze
    }

    allow(mock_ec2).to receive(:instances).with(anything) { Hash.new {} }
    allow(mock_ec2).to receive(:instances).with(no_args) { Hash.new {} }
    mock_ec2
  end

  def mock_ec2_instance_state(name, code)
    ec2_instance_state = double('ec2_instance_state')
    # Possible values: pending, running, shutting-down, terminated, stopping, stopped
    allow(ec2_instance_state).to receive(:name) { name }
    # Possible values: 0, 16, 32, 48, 64, 80
    allow(ec2_instance_state).to receive(:code) { code }
    ec2_instance_state
  end

  def mock_ec2_instance(ec2_resource, id, state_name, state_code, tags)
    # Add default tags.
    tags[:StackPrefix] = TEST_STACK_PREFIX if tags[:StackPrefix].nil?
    tags[:Component] = ec2_resource.ec2_component if tags[:Component].nil?
    tags[:Name] = ec2_resource.ec2_name if tags[:Name].nil?

    ec2_instance = double('ec2_instance')
    allow(ec2_instance).to receive(:instance_id) { id }
    allow(ec2_instance).to receive(:state) { mock_ec2_instance_state(state_name, state_code) }
    ec2_tags = []
    tags.each do |key, value|
      ec2_tags.push(ec2_tag(id, key.to_s, value))
    end
    allow(ec2_instance).to receive(:tags) { ec2_tags }
    allow(ec2_instance).to receive(:inspect) { "mock_ec2_instance [#{ec2_instance.tags}]" }
    ec2_instance
  end

  private

  # Intentional replication of AWS instance filter logic for use by mock EC2 Resource.
  def filter_instances(instances, filters)
    filtered = instances
    # Include only instances that match all filters.
    filters.each do |filter|
      key, value = filter.first
      filtered = filtered.select { |i|
        found_tag = i.tags.find { |t|
          t.key == key.to_s
        }
        next if found_tag.nil?

        found_tag.value == value
      }
    end
    filtered
  end

  def ec2_tag(resource_id, key, value)
    ec2_tag = double('ec2_tag')
    allow(ec2_tag).to receive(:resource_id) { resource_id }
    allow(ec2_tag).to receive(:key) { key }
    allow(ec2_tag).to receive(:value) { value }
    allow(ec2_tag).to receive(:inspect) { "mock_tag [#{resource_id}, #{key}, #{value}]" }
    ec2_tag
  end
end

module AwsCloudWatchMocker
  def mock_cloud_watch
    mock_cloud_watch = double('mock_cloud_watch')
    mock_list_metrics_output = double('mock_list_metrics_output')
    allow(mock_list_metrics_output).to receive(:metrics) { [] }
    allow(mock_list_metrics_output).to receive(:next_token) { nil }
    allow(mock_cloud_watch).to receive(:list_metrics) { mock_list_metrics_output }
    mock_cloud_watch
  end

  def mock_cloud_watch_metric(metrics, metric_name, instance_ids = [])
    mock_metrics = []
    instance_ids.each do |instance_id|
      mock_metric = double('mock_metric')
      allow(mock_metric).to receive(:metric_name) { metric_name }

      mock_dimension_filter = double('mock_dimension_filter')
      allow(mock_dimension_filter).to receive(:name) { 'InstanceId' }
      allow(mock_dimension_filter).to receive(:value) { instance_id }
      allow(mock_metric).to receive(:dimensions) { [mock_dimension_filter] }

      mock_metrics.push(mock_metric)
    end

    metrics[metric_name] = mock_metrics
  end

  def add_metrics(mock_cloud_watch, metrics, metric_name, instance_ids)
    instance_ids.each do |instance_id|
      mock_list_metrics_output = double('mock_list_metrics_output')
      allow(mock_list_metrics_output).to receive(:next_token) { nil }
      allow(mock_list_metrics_output).to receive(:metrics) { filter_by_instance(metrics[metric_name], instance_id) }
      allow(mock_cloud_watch).to receive(:list_metrics).with(
        hash_including(metric_name: metric_name,
                       dimensions: [hash_including(value: instance_id)])
      ) { mock_list_metrics_output }
    end
  end

  private

  # Intentional replication of AWS metric filter logic for use by mock CloudWatch Client.
  def filter_by_instance(mock_metrics, instance_id)
    mock_metrics.select { |mock_metric|
      instance_id == mock_metric.dimensions[0].value
    }
  end
end

# module AwsCloudWatchLogsMocker
#   def mock_cloud_watch_logs
#     mock_cloud_watch_logs = double('mock_cloud_watch_logs')
#
#     # loggroup_name = "#{@descriptor.stack_prefix_in}#{log_stream_name}"
#     # log_stream_name = "#{@descriptor.ec2.component}/#{instance_id}"
#
#     allow(mock_list_metrics_output).to receive(:metrics) { [] }
#     allow(mock_cloud_watch).to receive(:list_metrics) { mock_list_metrics_output }
#     mock_cloud_watch
#   end
# end
