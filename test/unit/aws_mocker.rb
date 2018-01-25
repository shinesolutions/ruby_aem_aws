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

module AwsAutoScalingMocker
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
  def mock_ec2
    mock_ec2 = double('mock_ec2')
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

  # rubocop:disable ParameterLists
  def add_instance(mock_ec2, instances, instance_filter, id, state, tags = {})
    # Add default tags.
    tags[:StackPrefix] = TEST_STACK_PREFIX if tags[:StackPrefix].nil?
    tags[:Component] = @instance_component if tags[:Component].nil?
    tags[:Name] = @instance_name if tags[:Name].nil?

    instances.push(mock_ec2_instance(id, state, tags))
    allow(mock_ec2).to receive(:instances).with(anything) { -> { filter_instances(instances, instance_filter) }.call }
    allow(mock_ec2).to receive(:instances).with(no_args) { -> { filter_instances(instances, instance_filter) }.call }
  end
  # rubocop:enable ParameterLists

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

  private def mock_ec2_instance(id, state, tags)
    ec2_instance = double('ec2_instance')
    allow(ec2_instance).to receive(:instance_id) { id }
    allow(ec2_instance).to receive(:state) { mock_ec2_instance_state(state) }
    ec2_tags = []
    tags.each do |key, value|
      ec2_tags.push(ec2_tag(id, key.to_s, value))
    end
    allow(ec2_instance).to receive(:tags) { ec2_tags }
    ec2_instance
  end

  private def ec2_tag(resource_id, key, value)
    ec2_tag = double('ec2_tag')
    allow(ec2_tag).to receive(:resource_id) { resource_id }
    allow(ec2_tag).to receive(:key) { key }
    allow(ec2_tag).to receive(:value) { value }
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

  def mock_cloud_watch_metric(mock_cloud_watch, metric_name)
    mock_metric = double('mock_metric')
    allow(mock_metric).to receive(:metric_name) { metric_name }
    mock_list_metrics_output = double('mock_list_metrics_output')
    allow(mock_list_metrics_output).to receive(:metrics) { [mock_metric] }
    allow(mock_cloud_watch).to receive(:list_metrics).with(hash_including(metric_name: metric_name)) { mock_list_metrics_output }
  end
end
