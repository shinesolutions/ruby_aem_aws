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
require_relative '../../../../lib/ruby_aem_aws/component/author'

author_primary = RubyAemAws::Component::AuthorPrimary.new(nil, nil, nil)

describe author_primary do
  it_behaves_like 'a single instance accessor'
  it_behaves_like 'a healthy_instance_state_verifier'
  it_behaves_like 'a single metric_verifier'
end

describe 'AuthorPrimary' do
  before do
    # These will be used as default tag values when mocking ec2 instances.
    @ec2_component = RubyAemAws::Component::AuthorPrimary::EC2_COMPONENT
    @ec2_name = RubyAemAws::Component::AuthorPrimary::EC2_NAME
    @instance_filter = [
      { StackPrefix: TEST_STACK_PREFIX },
      { Component: @ec2_component },
      { Name: @ec2_name }
    ].freeze

    @mock_ec2 = mock_ec2_resource
    @mock_cloud_watch = mock_cloud_watch
  end

  it_has_behaviour 'single instance accessibility' do
    let(:component) { mock_author_primary }
  end

  it_has_behaviour 'metrics via single verifier' do
    let(:component) { mock_author_primary }
  end

  private def mock_author_primary
    author = RubyAemAws::Component::Author.new(TEST_STACK_PREFIX, @mock_ec2, nil, nil, @mock_cloud_watch)
    author.author_primary
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances, @instance_filter)
  end
end
