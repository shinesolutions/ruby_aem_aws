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
require_relative 'examples/component_grouped'
require_relative 'examples/verify_health_grouped'
require_relative 'examples/verify_metric_grouped'
require_relative '../../../../lib/ruby_aem_aws/component/author_dispatcher'

author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new({ stack_prefix: nil }, nil, nil, nil)
describe author_dispatcher do
  it_behaves_like 'a grouped instance accessor'
  it_behaves_like 'a healthy_instance_count_verifier'
end

describe 'AuthorDispatcher.health_state and .healthy?' do
  before do
    # These will be used as default tag values when mocking ec2 instances.
    @ec2_component = RubyAemAws::Component::AuthorDispatcher::EC2_COMPONENT
    @ec2_name = RubyAemAws::Component::AuthorDispatcher::EC2_NAME
    @instance_filter = [
      { StackPrefix: TEST_STACK_PREFIX },
      { Component: @ec2_component },
      { Name: @ec2_name }
    ].freeze

    @mock_ec2 = mock_ec2_resource
    @mock_elb = mock_elb_client(RubyAemAws::Component::AuthorDispatcher::ELB_ID,
                                RubyAemAws::Component::AuthorDispatcher::ELB_NAME)
    mock_asg = mock_asg(@ec2_component)
    @mock_as = mock_asg.first
    @asg = mock_asg.second

    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze
  end

  it_has_behaviour 'grouped instance accessibility' do
    let(:component) { mock_author_dispatcher }
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (1)' do
    allow(@asg).to receive(:desired_capacity) { 1 }
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_dispatcher.health_state).to equal :ready
    expect(mock_author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (2)' do
    allow(@asg).to receive(:desired_capacity) { 2 }
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_dispatcher.health_state).to equal :recovering
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB running instances (1/2) against ASG desired capacity (2)' do
    allow(@asg).to receive(:desired_capacity) { 2 }
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_UNHEALTHY)

    expect(mock_author_dispatcher.health_state).to equal :recovering
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB running instances (2) against ASG desired capacity (1)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY)
    allow(@asg).to receive(:desired_capacity) { 1 }

    expect(mock_author_dispatcher.health_state).to equal :scaling
    expect(mock_author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB running instances (1/2) against ASG desired capacity (1)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_UNHEALTHY)
    allow(@asg).to receive(:desired_capacity) { 1 }

    expect(mock_author_dispatcher.health_state).to equal :ready
    expect(mock_author_dispatcher.healthy?).to equal true
  end

  it 'verifies ELB instances (0) against ASG desired capacity (0)' do
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(mock_author_dispatcher.health_state).to equal :misconfigured
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB running instances (1) against ASG desired capacity (0)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(mock_author_dispatcher.health_state).to equal :misconfigured
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB non-running instances (1) against ASG desired capacity (0)' do
    add_instance(@instance_1_id, INSTANCE_STATE_UNHEALTHY)
    allow(@asg).to receive(:desired_capacity) { 0 }

    expect(mock_author_dispatcher.health_state).to equal :misconfigured
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  it 'verifies ELB does not exist' do
    allow(@mock_elb).to receive(:describe_tags) { mock_elb_describe_tags_output(mock_elb_tag_description(@elb_name)) }

    expect(mock_author_dispatcher.health_state).to equal :no_elb
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  it 'verifies ASG does not exist' do
    allow(@asg).to receive(:tags) { [] }

    expect(mock_author_dispatcher.health_state).to equal :no_asg
    expect(mock_author_dispatcher.healthy?).to equal false
  end

  private def mock_author_dispatcher
    RubyAemAws::Component::AuthorDispatcher.new(TEST_STACK_PREFIX, @mock_ec2, @mock_elb, @mock_as)
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances, @instance_filter)
    add_elb_instances(@mock_elb, @instances) if @mock_elb
    add_asg_instances(@asg, @instances) if @asg
  end
end
