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
  def mock_as_instance(id, status)
    as_instance = Aws::AutoScaling::Types::Instance.new
    allow(as_instance).to receive(:instance_id) { id }
    allow(as_instance).to receive(:health_status) { status }
    as_instance
  end

  def mock_as_tag(key, value)
    as_tag = Aws::AutoScaling::Types::TagDescription.new
    allow(as_tag).to receive(:key) { key }
    allow(as_tag).to receive(:value) { value }

    allow(as_tag).to receive(:to_s) { "#{key} : #{value}" }
    allow(as_tag).to receive(:inspect) { "#{key} : #{value}" }
    as_tag
  end

  def mock_as_group(name, desired_capacity, instances, *tags)
    as_group = Aws::AutoScaling::Types::AutoScalingGroup.new
    allow(as_group).to receive(:auto_scaling_group_name) { name }
    allow(as_group).to receive(:desired_capacity) { desired_capacity }
    allow(as_group).to receive(:instances) { instances }
    allow(as_group).to receive(:tags) { tags }
    as_group
  end

  def mock_as_groups_type(*as_groups)
    as_groups_type = Aws::AutoScaling::Types::AutoScalingGroupsType.new
    allow(as_groups_type).to receive(:auto_scaling_groups) { as_groups }
    as_groups_type
  end

  def mock_elb_instance(id)
    elb_instance = Aws::ElasticLoadBalancing::Types::Instance.new
    allow(elb_instance).to receive(:instance_id) { id }
    elb_instance
  end

  def mock_lb_description(elb_name, instances)
    lb_description = Aws::ElasticLoadBalancing::Types::LoadBalancerDescription.new
    allow(lb_description).to receive(:load_balancer_name) { elb_name }
    allow(lb_description).to receive(:instances) { instances }
    lb_description
  end

  def mock_elb_tag(key, value)
    elb_tag = Aws::ElasticLoadBalancing::Types::Tag.new
    allow(elb_tag).to receive(:key) { key }
    allow(elb_tag).to receive(:value) { value }

    allow(elb_tag).to receive(:to_s) { "#{key} : #{value}" }
    allow(elb_tag).to receive(:inspect) { "#{key} : #{value}" }
    elb_tag
  end

  def mock_elb_tag_description(elb_name, *tags)
    elb_tag_description = Aws::ElasticLoadBalancing::Types::TagDescription.new
    allow(elb_tag_description).to receive(:load_balancer_name) { elb_name }
    allow(elb_tag_description).to receive(:tags) { tags }
    elb_tag_description
  end

  def mock_elb_describe_tags_output(*tag_descriptions)
    elb_describe_tags_output = Aws::ElasticLoadBalancing::Types::DescribeTagsOutput.new
    allow(elb_describe_tags_output).to receive(:tag_descriptions) { tag_descriptions }
    elb_describe_tags_output
  end

  def mock_elb_access_points(*lb_descriptions)
    elb_access_points = Aws::ElasticLoadBalancing::Types::DescribeAccessPointsOutput.new
    allow(elb_access_points).to receive(:load_balancer_descriptions) { lb_descriptions }
    elb_access_points
  end

  def mock_ec2_instance_state(name)
    ec2_instance_state = Aws::EC2::Types::InstanceState.new
    # Possible values: pending, running, shutting-down, terminated, stopping, stopped
    allow(ec2_instance_state).to receive(:name) { name }
    ec2_instance_state
  end

  def mock_ec2_instance(id, state, tags)
    ec2_instance = Aws::EC2::Instance.new(id)
    allow(ec2_instance).to receive(:id) { id }
    allow(ec2_instance).to receive(:state) { mock_ec2_instance_state(state) }
    ec2_tags = []
    tags.each do |key, value|
      ec2_tags.push(ec2_tag(id, key.to_s, value))
    end
    allow(ec2_instance).to receive(:tags) { ec2_tags }
    ec2_instance
  end

  private def ec2_tag(resource_id, key, value)
    Aws::EC2::Tag.new(resource_id, key, value)
  end
end
