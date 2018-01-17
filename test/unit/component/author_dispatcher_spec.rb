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

author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(nil, nil, nil, nil)
describe author_dispatcher do
  it_behaves_like 'a health_checker'
end

describe 'AuthorDispatcher.healthy?' do
  module self::TestConstants
    EC2_NAME = RubyAemAws::Component::AuthorDispatcher::EC2_NAME
    EC2_COMPONENT = RubyAemAws::Component::AuthorDispatcher::EC2_COMPONENT

    ELB_NAME = RubyAemAws::Component::AuthorDispatcher::ELB_NAME
    ELB_ID = RubyAemAws::Component::AuthorDispatcher::ELB_ID

    ASG_NAME = 'asg-test'.freeze

    INSTANCE_1_ID = 'i-00525b1a281aee5b9'.freeze
    INSTANCE_1_COMPONENT = 'instance-a'.freeze

    INSTANCE_2_ID = 'i-00525b1a281aee5b7'.freeze
    INSTANCE_2_COMPONENT = 'instance-b'.freeze
  end

  private def add_instance(id, state, tags)
    @instances[id] = mock_ec2_instance(id, state, tags)
    allow(@mock_ec2).to receive(:instance).with(id) { @instances[id] }

    asg_instances = []
    elb_instances = []
    @instances.each do |id, instance|
      asg_instances.push(mock_as_instance(id, instance.state))
      elb_instances.push(mock_elb_instance(id))
    end
    allow(@asg).to receive(:instances) { asg_instances }

    allow(@mock_elb).to receive(:describe_load_balancers) {
      mock_elb_access_points(mock_lb_description(self.class::TestConstants::ELB_NAME, elb_instances))
    }
  end

  before do
    @mock_ec2 = double('mock_ec2')
    allow(@mock_ec2).to receive(:instance) { raise 'Instance not mocked' }

    @mock_elb = double('mock_elb')
    @mock_as = double('mock_as')

    @asg = mock_as_group(self.class::TestConstants::ASG_NAME,
                         1,
                         [],
                         mock_as_tag('StackPrefix', STACK_PREFIX),
                         mock_as_tag('Component', self.class::TestConstants::EC2_COMPONENT))
    allow(@mock_as).to receive(:describe_auto_scaling_groups) { mock_as_groups_type(@asg) }

    allow(@mock_elb).to receive(:describe_tags) {
      mock_elb_describe_tags_output(
        mock_elb_tag_description(self.class::TestConstants::ELB_NAME,
                                 mock_elb_tag('StackPrefix', STACK_PREFIX),
                                 mock_elb_tag('aws:cloudformation:logical-id', self.class::TestConstants::ELB_ID)))
    }
    allow(@mock_elb).to receive(:describe_load_balancers) {
      mock_elb_access_points(mock_lb_description(self.class::TestConstants::ELB_NAME, []))
    }

    @instances = Hash.new {}

    @author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(@mock_ec2, @mock_elb, @mock_as, STACK_PREFIX)
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (1)' do
    allow(@asg).to receive(:desired_capacity) { 1 }
    add_instance(self.class::TestConstants::INSTANCE_1_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX)

    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (2)' do
    allow(@asg).to receive(:desired_capacity) { 2 }
    add_instance(self.class::TestConstants::INSTANCE_1_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX)

    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB non-running instances (1/2) against ASG desired capacity (2)' do
    allow(@asg).to receive(:desired_capacity) { 2 }
    add_instance(self.class::TestConstants::INSTANCE_1_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX)
    add_instance(self.class::TestConstants::INSTANCE_2_ID,
                 INSTANCE_STATE_UNHEALTHY,
                 StackPrefix: STACK_PREFIX)

    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB instances (0) against ASG desired capacity (0)' do
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (0)' do
    add_instance(self.class::TestConstants::INSTANCE_1_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX)
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB non-running instances (1) against ASG desired capacity (0)' do
    add_instance(self.class::TestConstants::INSTANCE_1_ID,
                 INSTANCE_STATE_UNHEALTHY,
                 StackPrefix: STACK_PREFIX)
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(@author_dispatcher.healthy?).to equal true
  end
end

