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

require_relative '../abstract/grouped_component'
require_relative '../abstract/snapshot'
require_relative '../mixins/healthy_resource_verifier'
require_relative '../mixins/metric_verifier'
require_relative '../mixins/snapshot_verifier'

module RubyAemAws
  module Component
    # Interface to the AWS instance running the Orchestrator component of a full-set AEM stack.
    class Orchestrator
      attr_reader :descriptor, :ec2_resource, :asg_client, :cloud_watch_client, :cloud_watch_log_client
      include AbstractGroupedComponent
      include AbstractSnapshot
      include HealthyResourceVerifier
      include MetricVerifier
      include SnapshotVerifier

      EC2_COMPONENT = 'orchestrator'.freeze
      EC2_NAME = 'AEM Orchestrator'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param params Array of AWS Clients and Resource connections:
      # - AutoScalingClient: AWS AutoScalingGroup Client.
      # - CloudWatchClient: AWS Cloudwatch Client.
      # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
      # - Ec2Resource: AWS EC2 Resource connection.
      # @return new RubyAemAws::FullSet::Orchestrator
      def initialize(stack_prefix, params)
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new(EC2_COMPONENT, EC2_NAME))
        @asg_client = params[:AutoScalingClient]
        @cloud_watch_client = params[:CloudWatchClient]
        @cloud_watch_log_client = params[:CloudWatchLogsClient]
        @ec2_resource = params[:Ec2Resource]
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
