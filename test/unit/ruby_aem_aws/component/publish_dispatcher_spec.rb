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
require_relative '../../../../lib/ruby_aem_aws/component/publish_dispatcher'

publish_dispatcher = RubyAemAws::Component::PublishDispatcher.new(nil)

describe publish_dispatcher do
  it_behaves_like 'a health flagged component'
end

describe 'PublishDispatcher.healthy?' do
  before do
    @publish_dispatcher = RubyAemAws::Component::PublishDispatcher.new(TEST_STACK_PREFIX)
  end

  it 'runs healthy method' do
    expect { @publish_dispatcher.healthy? }.to raise_error(RubyAemAws::NotYetImplementedError)
  end
end
