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

require_relative '../spec_helper'
require_relative '../examples/verify_health'
require_relative '../examples/verify_metric'
require_relative '../../../lib/ruby_aem_aws'

describe 'Author Publish Dispatcher' do
  before do
    @component = init_consolidated.author_publish_dispatcher
  end

  it_has_behaviour 'health verifier' do
    let(:component) { @component }
  end

  it_has_behaviour 'metric verifier' do
    let(:component) { @component }
  end
end
