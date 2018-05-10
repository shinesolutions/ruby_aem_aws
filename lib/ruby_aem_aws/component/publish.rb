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
require_relative 'abstract_snapshot'
require_relative 'mixins/healthy_state_verifier'
require_relative 'mixins/metric_verifier'
require_relative 'mixins/snapshot_verifier'

module RubyAemAws
  module Component
    # Interface to the AWS instance running the Publish component of a full-set AEM stack.
    class Publish
      attr_reader :descriptor, :ec2_resource, :cloud_watch_client, :asg_client
      include AbstractGroupedComponent
      include AbstractSnapshot
      # Can't verify state by count as there's no ELB.
      include HealthyCountVerifier
      include MetricVerifier
      include SnapshotVerifier

      EC2_COMPONENT = 'publish'.freeze
      EC2_NAME = 'AEM Publish'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param ec2_resource AWS EC2 resource
      # @param asg_client AWS AutoScalingGroup client
      # @param cloud_watch_client AWS CloudWatch client
      # @return new RubyAemAws::FullSet::AuthorPrimary
      def initialize(stack_prefix, ec2_resource, asg_client, cloud_watch_client)
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new(EC2_COMPONENT, EC2_NAME))
        @ec2_resource = ec2_resource
        @asg_client = asg_client
        @cloud_watch_client = cloud_watch_client
      end

      def terminate_all_instances
        get_all_instances.each do |i|
          next if i.nil?
          i.terminate
          i.wait_until_terminated
        end
      end

      def terminate_random_instance
        instance = get_random_instance
        instance.terminate
        instance.wait_until_terminated
      end
    end
  end
end
