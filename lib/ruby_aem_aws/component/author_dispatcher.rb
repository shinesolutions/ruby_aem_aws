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
require_relative 'mixins/health_check_elb'
require_relative 'component_descriptor'

module RubyAemAws
  module Component
    # Interface to the AWS instance running the AuthorDispatcher component of a full-set AEM stack.
    class AuthorDispatcher
      include HealthCheckEC2
      include HealthCheckELB

      def get_ec2_client
        @ec2
      end

      def get_elb_client
        @elb
      end

      def get_descriptor
        @descriptor
      end

      # @param ec2 AWS EC2 client
      # @param elb AWS ELB client
      # @param stack_prefix AWS tag: StackPrefix
      # @return new RubyAemAws::FullSet::AuthorDispatcher
      def initialize(ec2, elb, stack_prefix)
        @ec2 = ec2
        @elb = elb
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new('author-dispatcher',
                                                                'AuthorDispatcher'),
                                              ELBDescriptor.new('AuthorDispatcherLoadBalancer',
                                                                'AEM Author Dispatcher Load Balancer'))
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

      def to_s
        'AuthorDispatcher(%s)' % @client
      end
=end
    end
  end
end
