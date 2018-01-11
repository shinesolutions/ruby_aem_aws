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

require 'ruby_aem_aws/component/author_dispatcher'
require 'ruby_aem_aws/component/author'
require 'ruby_aem_aws/component/chaos_monkey'
require 'ruby_aem_aws/component/orchestrator'
require 'ruby_aem_aws/component/publish_dispatcher'
require 'ruby_aem_aws/component/publish'

module RubyAemAws
  #
  class FullSetStack
    # Initialise a full set instance.
    #
    # @param client TODOs
    # @param stack_prefix TODO
    # @return new RubyAemAws::FullSetStack instance
    def initialize(client, stack_prefix)
      @client = client
      @stack_prefix = stack_prefix
    end

    def author_dispatcher
      RubyAemAws::Component::AuthorDispatcher.new(@client, @stack_prefix)
    end

    def author
      RubyAemAws::Component::Author.new(@client, @stack_prefix)
    end

    def chaos_monkey
      RubyAemAws::Component::ChaosMonkey.new(@client, @stack_prefix)
    end

    def orchestrator
      RubyAemAws::Component::Orchestrator.new(@client, @stack_prefix)
    end

    def publish
      RubyAemAws::Component::Publish.new(@client, @stack_prefix)
    end

    def publish_dispatcher
      RubyAemAws::Component::PublishDispatcher.new(@client, @stack_prefix)
    end
  end
end