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

require_relative 'component/author_dispatcher'
require_relative 'component/author'
require_relative 'component/chaos_monkey'
require_relative 'component/orchestrator'
require_relative 'component/publish_dispatcher'
require_relative 'component/publish'

module RubyAemAws
  # Factory for the full-set AEM stack component interfaces.
  class FullSetStack
    # @param ec2_resource AWS EC2 resource
    # @param elb_client AWS ELB client
    # @param autoscaling_client AWS AutoScaling client
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::FullSetStack instance
    def initialize(ec2_resource, elb_client, autoscaling_client, stack_prefix)
      @ec2_resource = ec2_resource
      @elb_client = elb_client
      @auto_scaling_client = autoscaling_client
      @stack_prefix = stack_prefix
    end

    # @return new RubyAemAws::Component::AuthorDispatcher instance
    def author_dispatcher
      RubyAemAws::Component::AuthorDispatcher.new(@ec2_resource, @elb_client, @auto_scaling_client, @stack_prefix)
    end

    # @return new RubyAemAws::Component::Author instance
    def author
      RubyAemAws::Component::Author.new(@ec2_resource, @stack_prefix)
    end

    # @return new RubyAemAws::Component::ChaosMonkey instance
    def chaos_monkey
      RubyAemAws::Component::ChaosMonkey.new(@ec2_resource, @stack_prefix)
    end

    # @return new RubyAemAws::Component::Orchestrator instance
    def orchestrator
      RubyAemAws::Component::Orchestrator.new(@ec2_resource, @stack_prefix)
    end

    # @return new RubyAemAws::Component::Publish instance
    def publish
      RubyAemAws::Component::Publish.new(@ec2_resource, @stack_prefix)
    end

    # @return new RubyAemAws::Component::PublishDispatcher instance
    def publish_dispatcher
      RubyAemAws::Component::PublishDispatcher.new(@ec2_resource, @stack_prefix)
    end
  end
end
