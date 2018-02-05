# Copyright 2018 Shine Solutions
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
  def add_instance(env, id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?

    ec2_resource = env.ec2_resource
    @instances[id] = mock_ec2_instance(ec2_resource, id, state, tags)
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
    as_groups_type
  end
end

module AwsElasticLoadBalancerMocker
  def add_elb_instances(mock_elb, instances)
    elb_instances = []
    instances.each_key do |instance_id|
      elb_instances.push(mock_elb_instance(instance_id))
    end
    allow(mock_elb).to receive(:describe_load_balancers) {
      mock_elb_access_points(mock_lb_description(mock_elb.load_balancer_name, elb_instances))
    }
  end

  def mock_elb_client(load_balancer_id, load_balancer_name)
    mock_elb = double('mock_elb')

    # Store the load_balancer_name in a non-doubled method for convenience in testing
    allow(mock_elb).to receive(:load_balancer_name) { load_balancer_name }

    allow(mock_elb).to receive(:describe_tags) {
      mock_elb_describe_tags_output(
        mock_elb_tag_description(load_balancer_name,
                                 mock_elb_tag('StackPrefix', TEST_STACK_PREFIX),
                                 mock_elb_tag('aws:cloudformation:logical-id', load_balancer_id))
      )
    }
    allow(mock_elb).to receive(:describe_load_balancers) {
      mock_elb_access_points(mock_lb_description(load_balancer_name, []))
    }
    mock_elb
  end

  def mock_elb_instance(id)
    elb_instance = double('elb_instance')
    allow(elb_instance).to receive(:instance_id) { id }
    elb_instance
  end

  def mock_lb_description(elb_name, instances)
    lb_description = double('lb_description')
    allow(lb_description).to receive(:load_balancer_name) { elb_name }
    allow(lb_description).to receive(:instances) { instances }
    lb_description
  end

  def mock_elb_tag(key, value)
    elb_tag = double('elb_tag')
    allow(elb_tag).to receive(:key) { key }
    allow(elb_tag).to receive(:value) { value }

    allow(elb_tag).to receive(:to_s) { "#{key} : #{value}" }
    allow(elb_tag).to receive(:inspect) { "#{key} : #{value}" }
    elb_tag
  end

  def mock_elb_tag_description(elb_name, *tags)
    elb_tag_description = double('elb_tag_description')
    allow(elb_tag_description).to receive(:load_balancer_name) { elb_name }
    allow(elb_tag_description).to receive(:tags) { tags }
    elb_tag_description
  end

  def mock_elb_describe_tags_output(*tag_descriptions)
    elb_describe_tags_output = double('describe_tags_output')
    allow(elb_describe_tags_output).to receive(:tag_descriptions) { tag_descriptions }
    elb_describe_tags_output
  end

  def mock_elb_access_points(*lb_descriptions)
    elb_access_points = double('elb_access_points')
    allow(elb_access_points).to receive(:load_balancer_descriptions) { lb_descriptions }
    elb_access_points
  end
end

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

  def mock_ec2_instance_state(name)
    ec2_instance_state = double('ec2_instance_state')
    # Possible values: pending, running, shutting-down, terminated, stopping, stopped
    allow(ec2_instance_state).to receive(:name) { name }
    ec2_instance_state
  end

  def mock_ec2_instance(ec2_resource, id, state, tags)
    # Add default tags.
    tags[:StackPrefix] = TEST_STACK_PREFIX if tags[:StackPrefix].nil?
    tags[:Component] = ec2_resource.ec2_component if tags[:Component].nil?
    tags[:Name] = ec2_resource.ec2_name if tags[:Name].nil?

    ec2_instance = double('ec2_instance')
    allow(ec2_instance).to receive(:instance_id) { id }
    allow(ec2_instance).to receive(:state) { mock_ec2_instance_state(state) }
    ec2_tags = []
    tags.each do |key, value|
      ec2_tags.push(ec2_tag(id, key.to_s, value))
    end
    allow(ec2_instance).to receive(:tags) { ec2_tags }
    allow(ec2_instance).to receive(:inspect) { "mock_ec2_instance [#{ec2_instance.tags}]" }
    ec2_instance
  end

  # Intentional replication of AWS instance filter logic for use by mock EC2 Resource.
  private def filter_instances(instances, filters)
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

  private def ec2_tag(resource_id, key, value)
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
      allow(mock_list_metrics_output).to receive(:metrics) { filter_by_instance(metrics[metric_name], instance_id) }
      allow(mock_cloud_watch).to receive(:list_metrics).with(
        hash_including(metric_name: metric_name,
                       dimensions: [hash_including(value: instance_id)])
      ) { mock_list_metrics_output }
    end
  end

  # Intentional replication of AWS metric filter logic for use by mock CloudWatch Client.
  private def filter_by_instance(mock_metrics, instance_id)
    mock_metrics.select { |mock_metric|
      instance_id == mock_metric.dimensions[0].value
    }
  end
end
