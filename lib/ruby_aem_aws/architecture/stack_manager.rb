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

require_relative '../component/stack_manager_resources'

module RubyAemAws
  # Interface to interact with AEM StackManager
  class StackManager
    attr_reader :sm_resources, :cloudformation_client
    # @param stack_prefix AWS tag: StackPrefix
    # @param dynamodb_client AWS DynamoDB client
    # @param s3_client AWS S3 client
    # @param s3_resource AWS S3 resource
    # @param cloudformation_client AWS Cloudformation Client
    # @param cloud_watch_client AWS Cloudwatch Client
    # @param cloud_watch_log_client AWS Cloudwatch Log Client
    # @return new RubyAemAws::StackManager instance
    def initialize(stack_prefix, dynamodb_client, s3_client, s3_resource, cloudformation_client, cloud_watch_client, cloud_watch_log_client)
      @sm_resources = RubyAemAws::Component::StackManagerResources.new(dynamodb_client, s3_client, s3_resource, cloud_watch_client, cloud_watch_log_client)
      @stack_prefix = stack_prefix
      @cloudformation_client = cloudformation_client
    end
  end
end
