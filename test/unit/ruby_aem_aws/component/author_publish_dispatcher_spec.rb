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
require_relative 'examples/check_methods_exist'
require_relative '../../../../lib/ruby_aem_aws/component/author_publish_dispatcher'

author_publish_dispatcher = RubyAemAws::Component::AuthorPublishDispatcher.new({ stack_prefix: nil }, nil)

describe author_publish_dispatcher do
  it_behaves_like 'a healthy_instance_state_verifier'
end

describe 'AuthorPublishDispatcher.healthy?' do
  before do
    # These will be used as default tag values when mocking ec2 instances.
    @ec2_component = RubyAemAws::Component::AuthorPublishDispatcher::EC2_COMPONENT
    @ec2_name = RubyAemAws::Component::AuthorPublishDispatcher::EC2_NAME
    @instance_filter = [
      { StackPrefix: TEST_STACK_PREFIX },
      { Component: @ec2_component },
      { Name: @ec2_name }
    ].freeze

    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze
    @instance_3_id = 'i-00525b1a281aee5b5'.freeze

    @mock_ec2 = mock_ec2_resource

    @author_dispatcher = RubyAemAws::Component::AuthorPublishDispatcher.new(TEST_STACK_PREFIX, @mock_ec2)
  end

  it 'verifies EC2 running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies EC2 not-running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_UNHEALTHY)

    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies EC2 running instance (one of many)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY, Name: 'bob')
    add_instance(@instance_3_id, INSTANCE_STATE_UNHEALTHY, Component: 'bob')

    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies EC2 non-running instance (one of many)' do
    add_instance(@instance_1_id, INSTANCE_STATE_UNHEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY, Name: 'bob')
    add_instance(@instance_3_id, INSTANCE_STATE_UNHEALTHY, Component: 'bob')

    expect(@author_dispatcher.healthy?).to equal false
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances, @instance_filter)
  end
end
