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
require_relative 'mixins/health_check_ec2'
require_relative 'component_descriptor'

module RubyAemAws
  module Component
    # Interface to a single AWS instance running all three AEM components as a consolidated stack.
    class AuthorPublishDispatcher
      include HealthCheckEC2

      def get_client
        @client
      end

      def get_descriptor
        @descriptor
      end

      # @param client AWS EC2 client
      # @param stack_prefix AWS tag: StackPrefix
      # @return new RubyAemAws::Consolidated::AuthorPublishDispatcher instance
      def initialize(client, stack_prefix)
        @client = client
        @descriptor = ComponentDescriptor.new(stack_prefix, 'author-publish-dispatcher', 'AuthorPublishDispatcher', '')
      end
=begin
      def get_all_instances
      end

      def get_random_instance
      end

      def get_num_of_instances
      end

      def terminate_all_instances
      end

      def terminate_random_instance
      end

      def wait_until_healthy
      end
=end
    end
  end
end
