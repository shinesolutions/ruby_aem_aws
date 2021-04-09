# Copyright 2018-2021 Shine Solutions Group
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
require_relative 'examples/describe_grouped'
require_relative 'examples/verify_health_single'
require_relative 'examples/verify_metric_grouped'
require_relative '../../../../lib/ruby_aem_aws/component/publish'

publish = RubyAemAws::Component::Publish.new(nil, nil, nil, nil)

describe publish do
  it_behaves_like 'a grouped instance accessor'
  it_behaves_like 'a grouped instance describer'
  it_behaves_like 'a health by state verifier'
  it_behaves_like 'a grouped metric_verifier'
end

describe 'Publish' do
  before :each do
    @environment = environment_creator
  end

  it_has_behaviour 'grouped instance accessibility' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  it_has_behaviour 'grouped instance description' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  it_has_behaviour 'health via single verifier' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  it_has_behaviour 'metrics via grouped verifier' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  private

  def component_creator(environment)
    RubyAemAws::Component::Publish.new(TEST_STACK_PREFIX,
                                       environment.ec2_resource,
                                       environment.asg_client,
                                       environment.cloud_watch_client)
  end

  def environment_creator
    Aws::AemEnvironment.new(mock_ec2_resource(RubyAemAws::Component::Publish::EC2_COMPONENT,
                                              RubyAemAws::Component::Publish::EC2_NAME),
                            mock_asg_client(RubyAemAws::Component::Publish::EC2_COMPONENT),
                            nil,
                            mock_cloud_watch)
  end
end
