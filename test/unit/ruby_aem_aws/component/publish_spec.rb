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
require_relative 'examples/verify_health_single'
require_relative 'examples/verify_metric_single'
require_relative 'examples/verify_metric_grouped'
require_relative '../../../../lib/ruby_aem_aws/component/publish'

publish = RubyAemAws::Component::Publish.new(nil, nil, nil, nil)

describe publish do
  it_behaves_like 'a grouped instance accessor'
  it_behaves_like 'a healthy_instance_state_verifier'
  it_behaves_like 'a grouped metric_verifier'
end

describe 'Publish' do
  before do
    # These will be used as default tag values when mocking ec2 instances.
    @ec2_component = RubyAemAws::Component::Publish::EC2_COMPONENT
    @ec2_name = RubyAemAws::Component::Publish::EC2_NAME
    @instance_filter = [
      { StackPrefix: TEST_STACK_PREFIX },
      { Component: @ec2_component },
      { Name: @ec2_name }
    ].freeze

    @mock_ec2 = mock_ec2_resource
    mock_asg = mock_asg(@ec2_component)
    @mock_as = mock_asg.first
    @asg = mock_asg.second

    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze

    @metric_1_name = 'A test metric'
    @metric_2_name = 'Unmocked'

    @mock_cloud_watch = mock_cloud_watch
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])
  end

  it_has_behaviour 'grouped instance accessibility' do
    let(:component) { mock_publish }
  end

  it_has_behaviour 'metrics via single verifier' do
    let(:component) { mock_publish }
  end

  it_has_behaviour 'metrics via grouped verifier' do
    let(:component) { mock_publish }
  end

  it '.healthy? verifies EC2 running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_publish.healthy?).to equal true
  end

  it '.healthy? verifies no EC2 running instance' do
    expect(mock_publish.healthy?).to equal false
  end

  it '.metric_instances returns all instances with metric' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id, @instance_2_id])

    expect(mock_publish.metric_instances(@metric_1_name).length).to be == mock_publish.get_all_instances.length
  end

  it '.metric_instances returns only instances with metric' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_2_name, [@instance_2_id])

    expect(mock_publish.metric_instances(@metric_1_name).length).to be < mock_publish.get_all_instances.length
  end

  private def mock_publish
    RubyAemAws::Component::Publish.new(TEST_STACK_PREFIX, @mock_ec2, @mock_as, @mock_cloud_watch)
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances, @instance_filter)
    add_asg_instances(@asg, @instances) if @asg
  end
end
