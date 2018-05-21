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

require_relative '../component/author_publish_dispatcher'

module RubyAemAws
  # Factory for the consolidated AEM stack component interface.
  class ConsolidatedStack
    attr_reader :cloudformation_client

    # @param stack_prefix AWS tag: StackPrefix
    # @param params Array of AWS Clients and Resource connections:
    # - CloudFormationClient: AWS Cloudformation Client.
    # - CloudWatchClient: AWS Cloudwatch Client.
    # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
    # - Ec2Resource: AWS EC2 Resource connection.
    # @return new RubyAemAws::ConsolidatedStack instance
    def initialize(stack_prefix, params)
      @consolidated_aws_clients = {
        CloudWatchClient: params[:CloudWatchClient],
        CloudWatchLogsClient: params[:CloudWatchLogsClient],
        Ec2Resource: params[:Ec2Resource]
      }
      @cloudformation_client = cloudformation_client
      @stack_prefix = stack_prefix
    end

    # @param stack_prefix AWS tag: StackPrefix
    # @param consolidated_aws_clients Array of AWS Clients and Resource connections:
    # - CloudWatchClient: AWS Cloudwatch Client.
    # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
    # - Ec2Resource: AWS EC2 Resource connection.
    # @return new RubyAemAws::Component::AuthorPublishDispatcher instance
    def author_publish_dispatcher
      RubyAemAws::Component::AuthorPublishDispatcher.new(@stack_prefix, @consolidated_aws_clients)
    end
  end
end
