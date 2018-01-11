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

require_relative '../spec_helper'
require_relative '../../../lib/ruby_aem_aws/component/author_dispatcher'

shared_examples 'a health_checker' do
  context 'AuthorDispatcher' do
    it 'contains method' do
      is_expected.to respond_to(:healthy?)
    end
  end
end

@author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(nil,nil)

describe @author_dispatcher do
  before do
  end

  after do
  end

  describe 'AuthorDispatcher' do
    it_behaves_like 'a health_checker'
  end
end