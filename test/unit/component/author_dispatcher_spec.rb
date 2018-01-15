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
require 'ruby_aem_aws/constants'
require 'ruby_aem_aws/component/author_dispatcher'

ec2_double = Aws::EC2::Resource.new(region: Constants::REGION_DEFAULT)
elb_double = Aws::ElasticLoadBalancing::Client.new(region: Constants::REGION_DEFAULT)
asg_double = Aws::AutoScaling::Client.new(region: Constants::REGION_DEFAULT)

STACK_PREFIX = 'test-prefix'.freeze
author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(ec2_double, elb_double, asg_double, STACK_PREFIX)

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|

    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true

  end
end

describe author_dispatcher do
  it_behaves_like 'a health_checker'
end

describe 'AuthorDispatcher.healthy?' do
  it 'hits correct endpoints' do
    tag_asg_stack_prefix = double_tag('StackPrefix', STACK_PREFIX)
    tag_asg_component = double_tag('Component', RubyAemAws::Component::AuthorDispatcher::EC2_COMPONENT)
    asg = double_as_group(tag_asg_component, tag_asg_stack_prefix)
    allow(asg_double).to receive(:describe_auto_scaling_groups) { double_as_groups(asg) }

    INSTANCE_ID_1 = 'instance-1'.freeze

    # TODO configure ELB double
    # [{ instances: [{ instance_id: INSTANCE_ID_1 }] }]
    elb_access_points = double_elb_access_points
    allow(elb_double).to receive(:describe_load_balancers) { elb_access_points }

    # TODO configure EC2 double
    allow(ec2_double).to receive(:instance) { Aws::EC2::Instance.new(INSTANCE_ID_1) }

    expect(author_dispatcher.healthy?).to equal true
  end
end

private def double_tag(key, value)
  tag_double = Aws::AutoScaling::Types::Tag
  allow(tag_double).to receive(:key) { key }
  allow(tag_double).to receive(:value) { value }
  tag_double
end

def double_as_group(*tags)
  as_group = Aws::AutoScaling::Types::AutoScalingGroup.new
  allow(as_group).to receive(:tags) { tags }
  allow(as_group).to receive(:desired_capacity) { 1 }
  as_group
end

private def double_as_groups(*as_groups)
  as_groups_type = Aws::AutoScaling::Types::AutoScalingGroupsType.new
  allow(as_groups_type).to receive(:auto_scaling_groups) { as_groups }
  as_groups_type
end

private def double_elb_access_points(*lb_descriptions)
  elb_access_points = Aws::ElasticLoadBalancing::Types::DescribeAccessPointsOutput
  allow(elb_access_points).to receive(:load_balancer_descriptions) { lb_descriptions }
  elb_access_points
end
