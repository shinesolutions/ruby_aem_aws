# Copyright 2018-2021 Shine Solutions Group
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
      # @param params Array of AWS Clients and Resource connections:
      # - CloudWatchClient: AWS Cloudwatch Client.
      # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
      # - Ec2Resource: AWS EC2 Resource connection.
      # @return new RubyAemAws::Consolidated::AuthorPublishDispatcher instance
      def initialize(stack_prefix, params)
        @descriptor = ComponentDescriptor.new(stack_prefix,
                                              EC2Descriptor.new(EC2_COMPONENT, EC2_NAME))
        @cloud_watch_client = params[:CloudWatchClient]
        @cloud_watch_log_client = params[:CloudWatchLogsClient]
        @ec2_resource = params[:Ec2Resource]
      end

      def get_tags
        instance = get_instance
        instance.tags
      end
    end
  end
end
