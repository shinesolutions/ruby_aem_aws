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

require_relative '../component/author_dispatcher'
require_relative '../component/author'
require_relative '../component/chaos_monkey'
require_relative '../component/orchestrator'
require_relative '../component/publish_dispatcher'
require_relative '../component/publish'
require_relative '../mixins/metric_verifier'

module RubyAemAws
  # Factory for the full-set AEM stack component interfaces.
  class FullSetStack
    attr_reader :cloudformation_client, :cloud_watch_client
    include MetricVerifier

    # @param stack_prefix AWS tag: StackPrefix
    # @param params Array of AWS Clients and Resource connections:
    # - AutoScalingClient: AWS AutoScalingGroup Client.
    # - CloudFormationClient: AWS Cloudformation Client.
    # - CloudWatchClient: AWS Cloudwatch Client.
    # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
    # - Ec2Resource: AWS EC2 Resource connection.
    # - ElbClient: AWS ElasticLoadBalancer v2 Client.
    # @return new RubyAemAws::FullSetStack instance
    def initialize(stack_prefix, params)
      @author_aws_clients = {
        CloudWatchClient: params[:CloudWatchClient],
        CloudWatchLogsClient: params[:CloudWatchLogsClient],
        Ec2Resource: params[:Ec2Resource],
        ElbClient: params[:ElbClient]
      }

      @dispatcher_aws_clients = {
        AutoScalingClient: params[:AutoScalingClient],
        CloudWatchClient: params[:CloudWatchClient],
        CloudWatchLogsClient: params[:CloudWatchLogsClient],
        Ec2Resource: params[:Ec2Resource],
        ElbClient: params[:ElbClient]
      }

      @publish_aws_clients = {
        AutoScalingClient: params[:AutoScalingClient],
        CloudWatchClient: params[:CloudWatchClient],
        CloudWatchLogsClient: params[:CloudWatchLogsClient],
        Ec2Resource: params[:Ec2Resource]
      }

      @aem_java_aws_clients = {
        AutoScalingClient: params[:AutoScalingClient],
        CloudWatchClient: params[:CloudWatchClient],
        CloudWatchLogsClient: params[:CloudWatchLogsClient],
        Ec2Resource: params[:Ec2Resource]
      }

      @cloudformation_client = params[:CloudFormationClient]
      @cloud_watch_client = params[:CloudWatchClient]
      @stack_prefix = stack_prefix
    end

    # @return new RubyAemAws::Component::AuthorDispatcher instance
    def author_dispatcher
      RubyAemAws::Component::AuthorDispatcher.new(@stack_prefix, @dispatcher_aws_clients)
    end

    # @return new RubyAemAws::Component::Author instance
    def author
      RubyAemAws::Component::Author.new(@stack_prefix, @author_aws_clients)
    end

    # @return new RubyAemAws::Component::ChaosMonkey instance
    def chaos_monkey
      RubyAemAws::Component::ChaosMonkey.new(@stack_prefix, @aem_java_aws_clients)
    end

    # @return new RubyAemAws::Component::Orchestrator instance
    def orchestrator
      RubyAemAws::Component::Orchestrator.new(@stack_prefix, @aem_java_aws_clients)
    end

    # @return new RubyAemAws::Component::Publish instance
    def publish
      RubyAemAws::Component::Publish.new(@stack_prefix, @publish_aws_clients)
    end

    # @return new RubyAemAws::Component::PublishDispatcher instance
    def publish_dispatcher
      RubyAemAws::Component::PublishDispatcher.new(@stack_prefix, @dispatcher_aws_clients)
    end
  end
end
