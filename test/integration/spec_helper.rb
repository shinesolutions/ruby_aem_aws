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

require 'simplecov'
SimpleCov.start

RSpec.configure do |config|
  # Improve test output
  config.alias_it_should_behave_like_to :it_has_behaviour, 'has behaviour:'
end

require_relative '../../lib/ruby_aem_aws'

DEFAULT_REGION = 'ap-southeast-2'.freeze

def init_client
  region = { region: ENV['AWS_REGION'] || DEFAULT_REGION }
  RubyAemAws::AemAws.new(region)
end

DEFAULT_STACK_PREFIX = 'sandpit'.freeze

def init_consolidated
  stack_prefix = { stack_prefix: ENV['STACK_PREFIX'] || DEFAULT_STACK_PREFIX }
  init_client.consolidated(stack_prefix)
end

def init_full_set
  stack_prefix = { stack_prefix: ENV['STACK_PREFIX'] || DEFAULT_STACK_PREFIX }
  init_client.full_set(stack_prefix)
end
