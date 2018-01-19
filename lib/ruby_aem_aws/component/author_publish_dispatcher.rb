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

require 'aws-sdk'
require_relative 'mixins/healthy_instance_state_verifier'
require_relative 'abstract_component'
require_relative 'component_descriptor'

module RubyAemAws
  module Component
    # Interface to a single AWS instance running all three AEM components as a consolidated stack.
    class AuthorPublishDispatcher
      include AbstractComponent
      include HealthyInstanceStateVerifier

      def get_ec2_resource
        @ec2_resource
      end

      def get_descriptor
        @descriptor
      end

      EC2_COMPONENT = 'author-publish-dispatcher'.freeze
      EC2_NAME = 'AuthorPublishDispatcher'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param ec2_resource AWS EC2 resource
      # @return new RubyAemAws::Consolidated::AuthorPublishDispatcher instance
      def initialize(stack_prefix, ec2_resource)
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new(EC2_COMPONENT, EC2_NAME),
                                              nil)
        @ec2_resource = ec2_resource
      end

      # def get_all_instances

      # def get_random_instance

      # def get_num_of_instances

      # def terminate_all_instances

      # def terminate_random_instance

      # def wait_until_healthy
    end
  end
end
