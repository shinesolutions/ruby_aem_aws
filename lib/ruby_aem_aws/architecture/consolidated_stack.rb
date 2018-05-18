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
    # @param ec2_resource AWS EC2 client
    # @param cloud_watch_client AWS CloudWatch client
    # @param cloudformation_client AWS Cloudformation Client
    # @param cloud_watch_log_client AWS Cloudwatch Log Client
    # @return new RubyAemAws::ConsolidatedStack instance
    def initialize(stack_prefix, ec2_resource, cloud_watch_client, cloudformation_client, cloud_watch_log_client)
      @stack_prefix = stack_prefix
      @ec2_resource = ec2_resource
      @cloud_watch_client = cloud_watch_client
      @cloud_watch_log_client = cloud_watch_log_client
      @cloudformation_client = cloudformation_client
    end

    # @return new RubyAemAws::Component::AuthorPublishDispatcher instance
    def author_publish_dispatcher
      RubyAemAws::Component::AuthorPublishDispatcher.new(@stack_prefix, @ec2_resource, @cloud_watch_client, @cloud_watch_log_client)
    end
  end
end
