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
require_relative 'examples/instance_accessor'
require_relative 'examples/check_methods_exist'
require_relative '../../../../lib/ruby_aem_aws/component/author'

author_standby = RubyAemAws::Component::AuthorStandby.new(nil, nil, nil, nil, nil)

describe author_standby do
  it_behaves_like 'an instance accessor'
  it_behaves_like 'a healthy_instance_count_verifier'
  it_behaves_like 'a metric_verifier'
end

describe 'AuthorStandby' do
  before do
    # These will be used as default tag values when mocking ec2 instances.
    @ec2_component = RubyAemAws::Component::AuthorStandby::EC2_COMPONENT
    @ec2_name = RubyAemAws::Component::AuthorStandby::EC2_NAME
    @instance_filter = [
      { StackPrefix: TEST_STACK_PREFIX },
      { Component: @ec2_component },
      { Name: @ec2_name }
    ].freeze

    @mock_ec2 = mock_ec2_resource
    @mock_elb = mock_elb_client(RubyAemAws::Component::AuthorStandby::ELB_ID,
                                RubyAemAws::Component::AuthorStandby::ELB_NAME)
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

  it_has_behaviour 'instance accessibility' do
    let(:component) { mock_author_standby }
    let(:instance_count) { 0 }
  end

  it '.healthy? verifies EC2 running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_standby.healthy?).to equal true
  end

  it '.healthy? verifies no EC2 running instance' do
    expect(mock_author_standby.healthy?).to equal false
  end

  it '.metric? verifies metric exists' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])

    expect(mock_author_standby.metric?(@metric_1_name)).to equal true
  end

  it '.metric? verifies metric does not exist' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_standby.metric?(@metric_2_name)).to equal false
  end

  it '.metric_instances returns all instances with metric' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id, @instance_2_id])

    expect(mock_author_standby.metric_instances(@metric_1_name).length).to be == mock_author_standby.get_all_instances.length
  end

  it '.metric_instances returns only instances with metric' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(@instance_2_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_2_name, [@instance_2_id])

    expect(mock_author_standby.metric_instances(@metric_1_name).length).to be < mock_author_standby.get_all_instances.length
  end

  private def mock_author_standby
    author = RubyAemAws::Component::Author.new(TEST_STACK_PREFIX, @mock_ec2, @mock_as, @mock_elb, @mock_cloud_watch)
    author.author_standby
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances, @instance_filter)
    add_elb_instances(@mock_elb, @instances) if @mock_elb
    add_asg_instances(@asg, @instances) if @asg
  end
end
