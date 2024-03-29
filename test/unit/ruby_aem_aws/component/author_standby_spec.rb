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
require_relative 'examples/component_single'
require_relative 'examples/describe_single'
require_relative 'examples/verify_health_single'
require_relative 'examples/verify_metric_single'
require_relative '../../../../lib/ruby_aem_aws/component/author'

params = {
  CloudWatchClient: nil,
  CloudWatchLogsClient: nil,
  Ec2Resource: nil
}

author_standby = RubyAemAws::Component::AuthorStandby.new(nil, params)

describe author_standby do
  it_behaves_like 'a single instance accessor'
  it_behaves_like 'a single instance describer'
  it_behaves_like 'a health by state verifier'
  it_behaves_like 'a single metric_verifier'
end

describe 'AuthorStandby' do
  before :each do
    @environment = environment_creator
  end

  it_has_behaviour 'single instance accessibility' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  it_has_behaviour 'single instance description' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  it_has_behaviour 'health via single verifier' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  it_has_behaviour 'metrics via single verifier' do
    let(:environment) { @environment }
    let(:create_component) { ->(env) { component_creator(env) } }
  end

  private

  def component_creator(environment)
    params = {
      CloudWatchClient: environment.cloud_watch_client,
      CloudWatchLogsClient: nil,
      Ec2Resource: environment.ec2_resource
    }
    author = RubyAemAws::Component::Author.new(TEST_STACK_PREFIX,
                                               params)
    author.author_standby
  end

  def environment_creator
    Aws::AemEnvironment.new(mock_ec2_resource(RubyAemAws::Component::AuthorStandby::EC2_COMPONENT,
                                              RubyAemAws::Component::AuthorStandby::EC2_NAME),
                            nil,
                            nil,
                            mock_cloud_watch)
  end
end
