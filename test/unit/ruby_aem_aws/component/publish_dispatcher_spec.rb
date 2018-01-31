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
require_relative 'examples/verify_metric_single'
require_relative 'examples/verify_metric_grouped'
require_relative '../../../../lib/ruby_aem_aws/component/publish_dispatcher'

publish_dispatcher = RubyAemAws::Component::PublishDispatcher.new(nil, nil, nil)

describe publish_dispatcher do
  it_behaves_like 'a grouped instance accessor'
  it_behaves_like 'a healthy_instance_count_verifier'
  it_behaves_like 'a single metric_verifier'
  it_behaves_like 'a grouped metric_verifier'
end

describe 'PublishDispatcher.healthy?' do
  before do
    @publish_dispatcher = RubyAemAws::Component::PublishDispatcher.new(TEST_STACK_PREFIX, nil, nil)
  end

  it 'runs healthy method' do
    expect { @publish_dispatcher.healthy? }.to raise_error(RubyAemAws::NotYetImplementedError)
  end
end
