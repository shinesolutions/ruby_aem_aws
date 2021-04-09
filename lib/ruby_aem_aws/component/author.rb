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

require_relative 'author_primary'
require_relative 'author_standby'

module RubyAemAws
  module Component
    # Interface to the AWS instances running the Author components of a full-set AEM stack.
    class Author
      attr_reader :author_primary, :author_standby

      ELB_ID = 'AuthorLoadBalancer'.freeze
      ELB_NAME = 'AEM Author Load Balancer'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param params Array of AWS Clients and Resource connections:
      # - CloudWatchClient: AWS Cloudwatch Client.
      # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
      # - Ec2Resource: AWS EC2 Resource connection.
      # - ElbClient: AWS ElasticLoadBalancer v2 Client.
      # @return new RubyAemAws::FullSet::Author
      def initialize(stack_prefix, params)
        author_aws_clients = {
          CloudWatchClient: params[:CloudWatchClient],
          CloudWatchLogsClient: params[:CloudWatchLogsClient],
          Ec2Resource: params[:Ec2Resource]
        }

        @author_primary = Component::AuthorPrimary.new(stack_prefix, author_aws_clients)
        @author_standby = Component::AuthorStandby.new(stack_prefix, author_aws_clients)
        @ec2_resource = params[:Ec2Resource]
        @elb_client = params[:ElbClient]
      end

      # @return true, if all author instances are healthy
      def healthy?
        instance = 0
        instance += 1 if author_primary.healthy?
        instance += 1 if author_standby.healthy?
        return true unless instance < 2
      end

      # @return true, if all author instances are healthy
      def wait_until_healthy
        instance = 0
        instance += 1 if author_primary.wait_until_healthy.eql? true
        instance += 1 if author_standby.wait_until_healthy.eql? true
        return true unless instance < 2
      end

      def get_tags
        tags = []
        tags.push(author_primary.get_tags)
        tags.push(author_standby.get_tags)
        tags
      end
    end
  end
end
