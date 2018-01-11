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

require 'ruby_aem_aws/component/author_publish_dispatcher'

module RubyAemAws
  # Factory for the consolidated AEM stack component interface.
  class ConsolidatedStack
    # @param client AWS EC2 client
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::ConsolidatedStack instance
    def initialize(client, stack_prefix)
      @client = client
      @stack_prefix = stack_prefix
    end

    # @return new RubyAemAws::Component::AuthorPublishDispatcher instance
    def author_publish_dispatcher
      RubyAemAws::Component::AuthorPublishDispatcher.new(@client, @stack_prefix)
    end
  end
end
