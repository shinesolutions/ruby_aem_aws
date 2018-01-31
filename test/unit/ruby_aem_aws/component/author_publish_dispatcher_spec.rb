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
require_relative 'examples/component_single'
require_relative 'examples/verify_health_single'
require_relative 'examples/verify_metric_single'
require_relative '../../../../lib/ruby_aem_aws/component/author_publish_dispatcher'

author_publish_dispatcher = RubyAemAws::Component::AuthorPublishDispatcher.new(nil, nil, nil)

describe author_publish_dispatcher do
  it_behaves_like 'a single instance accessor'
  it_behaves_like 'a healthy_instance_state_verifier'
  it_behaves_like 'a single metric_verifier'
end

describe 'AuthorPublishDispatcher' do
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
    @mock_cloud_watch = mock_cloud_watch
  end

  it_has_behaviour 'single instance accessibility' do
    let(:component) { mock_author_publish_dispatcher }
  end

  it_has_behaviour 'metrics via single verifier' do
    let(:component) { mock_author_publish_dispatcher }
  end

  it 'verifies EC2 running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_publish_dispatcher.healthy?).to equal true
  end

  it 'verifies EC2 not-running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_UNHEALTHY)

    expect(mock_author_publish_dispatcher.healthy?).to equal false
  end

  it 'verifies EC2 running instance (one of many)' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY, Name: 'bob')
    add_instance(@instance_3_id, INSTANCE_STATE_UNHEALTHY, Component: 'bob')

    expect(mock_author_publish_dispatcher.healthy?).to equal true
  end

  it 'verifies EC2 non-running instance (one of many)' do
    add_instance(@instance_1_id, INSTANCE_STATE_UNHEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY, Name: 'bob')
    add_instance(@instance_3_id, INSTANCE_STATE_UNHEALTHY, Component: 'bob')

    expect(mock_author_publish_dispatcher.healthy?).to equal false
  end

  private def mock_author_publish_dispatcher
    RubyAemAws::Component::AuthorPublishDispatcher.new(TEST_STACK_PREFIX, @mock_ec2, @mock_cloud_watch)
  end

  private def add_instance(id, state = INSTANCE_STATE_HEALTHY, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances, @instance_filter)
  end
end
