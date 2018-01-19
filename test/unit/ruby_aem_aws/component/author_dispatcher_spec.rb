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

require_relative '../../spec_helper'
require_relative 'examples/health_checker'
require_relative '../../../../lib/ruby_aem_aws/component/author_dispatcher'

author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(nil, nil, nil, nil)
describe author_dispatcher do
  it_behaves_like 'a health flagged component'
  it_behaves_like 'a health state-aware component'
end

describe 'AuthorDispatcher.health_state and .healthy?' do
  before do
    @ec2_component = RubyAemAws::Component::AuthorDispatcher::EC2_COMPONENT
    @elb_id = RubyAemAws::Component::AuthorDispatcher::ELB_ID
    @elb_name = RubyAemAws::Component::AuthorDispatcher::ELB_NAME
    @asg_name = 'asg-test'.freeze
    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze

    @mock_ec2 = double('mock_ec2')
    allow(@mock_ec2).to receive(:instance) { raise 'Instance not mocked' }

    @mock_elb = double('mock_elb')
    @mock_as = double('mock_as')

    @asg = mock_as_group(@asg_name,
                         1,
                         [],
                         mock_as_tag('StackPrefix', TEST_STACK_PREFIX),
                         mock_as_tag('Component', @ec2_component))
    allow(@mock_as).to receive(:describe_auto_scaling_groups) { mock_as_groups_type(@asg) }

    allow(@mock_elb).to receive(:describe_tags) {
      mock_elb_describe_tags_output(
        mock_elb_tag_description(@elb_name,
                                 mock_elb_tag('StackPrefix', TEST_STACK_PREFIX),
                                 mock_elb_tag('aws:cloudformation:logical-id', @elb_id))
      )
    }
    allow(@mock_elb).to receive(:describe_load_balancers) {
      mock_elb_access_points(mock_lb_description(@elb_name, []))
    }

    @instances = Hash.new {}

    @author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(@mock_ec2, @mock_elb, @mock_as, TEST_STACK_PREFIX)
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (1)' do
    allow(@asg).to receive(:desired_capacity) { 1 }
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(@author_dispatcher.health_state).to equal :ready
    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (2)' do
    allow(@asg).to receive(:desired_capacity) { 2 }
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(@author_dispatcher.health_state).to equal :recovering
    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB running instances (1/2) against ASG desired capacity (2)' do
    allow(@asg).to receive(:desired_capacity) { 2 }
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_UNHEALTHY)

    expect(@author_dispatcher.health_state).to equal :recovering
    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB running instances (2) against ASG desired capacity (1)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY)
    allow(@asg).to receive(:desired_capacity) { 1 }

    expect(@author_dispatcher.health_state).to equal :scaling
    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB running instances (1/2) against ASG desired capacity (1)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_UNHEALTHY)
    allow(@asg).to receive(:desired_capacity) { 1 }

    expect(@author_dispatcher.health_state).to equal :ready
    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB instances (0) against ASG desired capacity (0)' do
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(@author_dispatcher.health_state).to equal :misconfigured
    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (0)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(@author_dispatcher.health_state).to equal :misconfigured
    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB non-running instances (1) against ASG desired capacity (0)' do
    add_instance(@instance_1_id, INSTANCE_STATE_UNHEALTHY)
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(@author_dispatcher.health_state).to equal :misconfigured
    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB does not exist' do
    allow(@mock_elb).to receive(:describe_tags) { mock_elb_describe_tags_output(mock_elb_tag_description(@elb_name)) }

    expect(@author_dispatcher.health_state).to equal :no_elb
    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies ASG does not exist' do
    allow(@asg).to receive(:tags) { [] }

    expect(@author_dispatcher.health_state).to equal :no_asg
    expect(@author_dispatcher.healthy?).to equal false
  end

  private

  def add_instance(id, state, tags = {})
    tags[:StackPrefix] = TEST_STACK_PREFIX if tags[:StackPrefix].nil?

    @instances[id] = mock_ec2_instance(id, state, tags)
    allow(@mock_ec2).to receive(:instance).with(id) { @instances[id] }

    asg_instances = []
    elb_instances = []
    @instances.each do |instance_id, instance|
      asg_instances.push(mock_as_instance(instance_id, instance.state))
      elb_instances.push(mock_elb_instance(instance_id))
    end
    allow(@asg).to receive(:instances) { asg_instances }

    allow(@mock_elb).to receive(:describe_load_balancers) {
      mock_elb_access_points(mock_lb_description(@elb_name, elb_instances))
    }
  end
end
