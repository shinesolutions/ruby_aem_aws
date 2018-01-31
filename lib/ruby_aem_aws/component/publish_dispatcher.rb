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

require_relative 'abstract_grouped_component'
require_relative 'mixins/healthy_instance_count_verifier'
require_relative 'mixins/metric_verifier'

module RubyAemAws
  module Component
    # Interface to the AWS instance running the PublishDispatcher component of a full-set AEM stack.
    class PublishDispatcher
      attr_reader :descriptor, :ec2_resource
      include AbstractGroupedComponent
      include HealthyInstanceCountVerifier
      include MetricVerifier

      EC2_COMPONENT = 'publish-dispatcher'.freeze
      EC2_NAME = 'AEM Publish Dispatcher'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param ec2_resource AWS EC2 resource
      # @return new RubyAemAws::FullSet::PublishDispatcher
      def initialize(stack_prefix, ec2_resource, cloud_watch_client)
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new(EC2_COMPONENT, EC2_NAME))
        @ec2_resource = ec2_resource
        @cloud_watch_client = cloud_watch_client
      end

      def healthy?
        raise NotYetImplementedError
      end

      # def terminate_all_instances

      # def terminate_random_instance

      # def wait_until_healthy
    end
  end
end
