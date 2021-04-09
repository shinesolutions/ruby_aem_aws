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

require_relative '../component/stack_manager_resources'

module RubyAemAws
  # Interface to interact with AEM StackManager
  class StackManager
    attr_reader :sm_resources, :cloudformation_client
    # @param stack_prefix AWS tag: StackPrefix
    # @param params Array of AWS Clients and Resource connections:
    # - CloudFormationClient: AWS Cloudformation Client.
    # - CloudWatchClient: AWS Cloudwatch Client.
    # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
    # - DynamoDBClient: AWS DynamoDB Client.
    # - S3Client: AWS S3 Client.
    # - S3Resource: AWS S3 Resource connection.
    # @return new RubyAemAws::StackManager instance
    def initialize(stack_prefix, params)
      stack_manager_aws_client = {
        CloudWatchClient: params[:CloudWatchClient],
        CloudWatchLogsClient: params[:CloudWatchLogsClient],
        DynamoDBClient: params[:DynamoDBClient],
        S3Client: params[:S3Client],
        S3Resource: params[:S3Resource]
      }

      @sm_resources = RubyAemAws::Component::StackManagerResources.new(stack_manager_aws_client)
      @cloudformation_client = params[:CloudFormationClient]
      @stack_prefix = stack_prefix
    end
  end
end
