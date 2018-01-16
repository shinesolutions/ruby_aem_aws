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

# require 'unit_helper'
require_relative '../spec_helper'
require_relative 'examples/health_checker'
require_relative '../../../lib/ruby_aem_aws/constants'
require_relative '../../../lib/ruby_aem_aws/component/author_dispatcher'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|

    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true

  end
end

author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(nil, nil, nil, nil)
describe author_dispatcher do
  it_behaves_like 'a health_checker'
end

describe 'AuthorDispatcher.healthy?' do
  STACK_PREFIX = 'test-prefix'.freeze

  before do
    # @mock_ec2 = Aws::EC2::Resource.new(region: Constants::REGION_DEFAULT)
    @mock_ec2 = double('mock_ec2')
    # @mock_elb = Aws::ElasticLoadBalancing::Client.new(region: Constants::REGION_DEFAULT)
    @mock_elb = double('mock_elb')
    # @mock_as = Aws::AutoScaling::Client.new(region: Constants::REGION_DEFAULT)
    @mock_as = double('mock_as')

    EC2_NAME = RubyAemAws::Component::AuthorDispatcher::EC2_NAME
    EC2_COMPONENT = RubyAemAws::Component::AuthorDispatcher::EC2_COMPONENT

    ELB_NAME = RubyAemAws::Component::AuthorDispatcher::ELB_NAME
    ELB_ID = RubyAemAws::Component::AuthorDispatcher::ELB_ID

    ASG_NAME = 'asg-test'.freeze
    INSTANCE_1_ID = 'i-00525b1a281aee5b9'.freeze
    INSTANCE_1_COMPONENT = 'instance-a'.freeze

    asg = mock_as_group(ASG_NAME,
                        1,
                        [mock_as_instance(INSTANCE_1_ID, Constants::ELB_INSTANCE_STATE_HEALTHY)],
                        mock_as_tag('StackPrefix', STACK_PREFIX),
                        mock_as_tag('Component', EC2_COMPONENT))
    allow(@mock_as).to receive(:describe_auto_scaling_groups) { mock_as_groups_type(asg) }

    instances = mock_elb_instance(INSTANCE_1_ID)
    elb_description = mock_lb_description(ELB_NAME, instances)
    elb_access_points = mock_elb_access_points(elb_description)
    allow(@mock_elb).to receive(:describe_load_balancers) { elb_access_points }

    allow(@mock_elb).to receive(:describe_tags) {
      mock_elb_describe_tags_output(mock_elb_tag_description(ELB_NAME,
                                                             mock_elb_tag('StackPrefix', STACK_PREFIX),
                                                             mock_elb_tag('aws:cloudformation:logical-id', ELB_ID)))
    }

    @instances = Hash.new {}
    allow(@mock_ec2).to receive(:instance) {
      raise 'Instance not mocked'
    }
    allow(@mock_ec2).to receive(:instance).with(INSTANCE_1_ID) {
      mock_ec2_instance(INSTANCE_1_ID,
                        Constants::ELB_INSTANCE_STATE_HEALTHY,
                        ec2_tag(INSTANCE_1_ID, 'StackPrefix', STACK_PREFIX))
    }

    @author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(@mock_ec2, @mock_elb, @mock_as, STACK_PREFIX)
  end

  it 'hits correct endpoints' do
    expect(@author_dispatcher.healthy?).to equal true
  end
end

private def mock_as_instance(id, status)
  as_instance = Aws::AutoScaling::Types::Instance.new
  allow(as_instance).to receive(:instance_id) { id }
  allow(as_instance).to receive(:health_status) { status }
  as_instance
end

private def mock_as_tag(key, value)
  as_tag = Aws::AutoScaling::Types::TagDescription.new
  allow(as_tag).to receive(:key) { key }
  allow(as_tag).to receive(:value) { value }

  allow(as_tag).to receive(:to_s) { "#{key} : #{value}" }
  allow(as_tag).to receive(:inspect) { "#{key} : #{value}" }
  as_tag
end

private def mock_as_group(name, desired_capacity, instances, *tags)
  as_group = Aws::AutoScaling::Types::AutoScalingGroup.new
  allow(as_group).to receive(:auto_scaling_group_name) { name }
  allow(as_group).to receive(:desired_capacity) { desired_capacity }
  allow(as_group).to receive(:instances) { instances }
  allow(as_group).to receive(:tags) { tags }
  as_group
end

private def mock_as_groups_type(*as_groups)
  as_groups_type = Aws::AutoScaling::Types::AutoScalingGroupsType.new
  allow(as_groups_type).to receive(:auto_scaling_groups) { as_groups }
  as_groups_type
end

private def mock_elb_instance(id)
  elb_instance = Aws::ElasticLoadBalancing::Types::Instance.new
  allow(elb_instance).to receive(:instance_id) { id }
  elb_instance
end

private def mock_lb_description(elb_name, *instances)
  lb_description = Aws::ElasticLoadBalancing::Types::LoadBalancerDescription.new
  allow(lb_description).to receive(:load_balancer_name) { elb_name }
  allow(lb_description).to receive(:instances) { instances }
  lb_description
end

private def mock_elb_tag(key, value)
  elb_tag = Aws::ElasticLoadBalancing::Types::Tag.new
  allow(elb_tag).to receive(:key) { key }
  allow(elb_tag).to receive(:value) { value }

  allow(elb_tag).to receive(:to_s) { "#{key} : #{value}" }
  allow(elb_tag).to receive(:inspect) { "#{key} : #{value}" }
  elb_tag
end

private def mock_elb_tag_description(elb_name, *tags)
  elb_tag_description = Aws::ElasticLoadBalancing::Types::TagDescription.new
  allow(elb_tag_description).to receive(:load_balancer_name) { elb_name }
  allow(elb_tag_description).to receive(:tags) { tags }
  elb_tag_description
end

private def mock_elb_describe_tags_output(*tag_descriptions)
  elb_describe_tags_output = Aws::ElasticLoadBalancing::Types::DescribeTagsOutput.new
  allow(elb_describe_tags_output).to receive(:tag_descriptions) { tag_descriptions }
  elb_describe_tags_output
end

private def mock_elb_access_points(*lb_descriptions)
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

def ec2_tag(resource_id, key, value)
  Aws::EC2::Tag.new(resource_id, key, value)
end

def mock_ec2_instance(id, state, *tags)
  instance = @instances.fetch(id, Aws::EC2::Instance.new(id))
  allow(instance).to receive(:state) { mock_ec2_instance_state(state) }
  allow(instance).to receive(:tags) { tags }
  @instances[id] = instance
  instance
end
