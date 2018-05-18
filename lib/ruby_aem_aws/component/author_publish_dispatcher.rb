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

require_relative '../abstract/single_component'
require_relative '../abstract/snapshot'
require_relative '../mixins/healthy_state_verifier'
require_relative '../mixins/metric_verifier'
require_relative 'component_descriptor'
require_relative '../mixins/snapshot_verifier'

module RubyAemAws
  module Component
    # Interface to a single AWS instance running all three AEM components as a consolidated stack.
    class AuthorPublishDispatcher
      attr_reader :descriptor, :ec2_resource, :cloud_watch_client, :cloud_watch_log_client
      include AbstractSingleComponent
      include AbstractSnapshot
      include HealthyStateVerifier
      include MetricVerifier
      include SnapshotVerifier

      EC2_COMPONENT = 'author-publish-dispatcher'.freeze
      EC2_NAME = 'AuthorPublishDispatcher'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param ec2_resource AWS EC2 resource
      # @param cloud_watch_client AWS CloudWatch client
      # @param cloud_watch_log_client AWS Cloudwatch Log Client
      # @return new RubyAemAws::Consolidated::AuthorPublishDispatcher instance
      def initialize(stack_prefix, ec2_resource, cloud_watch_client, cloud_watch_log_client)
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new(EC2_COMPONENT, EC2_NAME))
        @ec2_resource = ec2_resource
        @cloud_watch_client = cloud_watch_client
        @cloud_watch_log_client = cloud_watch_log_client
      end
    end
  end
end
