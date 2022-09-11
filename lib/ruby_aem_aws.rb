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

require 'aws-sdk-autoscaling'
require 'aws-sdk-cloudformation'
require 'aws-sdk-cloudwatch'
require 'aws-sdk-cloudwatchlogs'
require 'aws-sdk-dynamodb'
require 'aws-sdk-ec2'
require 'aws-sdk-elasticloadbalancingv2'
require 'aws-sdk-sns'
require 'aws-sdk-s3'
require_relative 'ruby_aem_aws/architecture/consolidated_stack'
require_relative 'ruby_aem_aws/architecture/full_set_stack'
require_relative 'ruby_aem_aws/architecture/stack_manager'

module RubyAemAws
  # AemAws class represents the AWS stack for AEM.
  class AemAws
    # @param conf configuration hash of the following configuration values:
    # - aws_region: the AWS region (eg ap-southeast-2)
    # - aws_access_key_id: the AWS access key
    # - aws_secret_access_key: the AWS secret access key
    # - aws_session_token: session token from STS
    # - aws_profile: AWS profile name
    # @return new RubyAemAws::AemAws instance
    def initialize(conf = {})
      conf[:aws_region] ||= Constants::REGION_DEFAULT
      conf[:aws_access_key_id] ||= Constants::ACCESS_KEY_ID
      conf[:aws_secret_access_key] ||= Constants::SECRET_ACCESS_KEY
      conf[:aws_session_token] ||= Constants::SESSION_TOKEN
      conf[:aws_profile] ||= Constants::PROFILE

      Aws.config.update(region: conf[:aws_region])

      credentials = Aws::Credentials.new(conf[:aws_access_key_id], conf[:aws_secret_access_key], conf[:aws_session_token]) unless conf[:aws_access_key_id].nil?
      credentials = Aws::SharedCredentials.new(profile_name: conf[:aws_profile]) unless conf[:aws_profile].nil?
      credentials = Aws::InstanceProfileCredentials.new if conf[:aws_profile].nil? && conf[:aws_access_key_id].nil?
      raise RubyAemAws::ArgumentError unless defined? credentials

      Aws.config.update(credentials: credentials)

      @aws = AwsCreator.create_aws
    end

    # Test connection to Amazon AWS
    #
    # @return One or more regions that are currently available.
    def test_connection
      result = []
      ec2_client = @aws[:Ec2Client]
      ec2_client.describe_regions.regions.each do |region|
        result.push("Region #{region.region_name} (#{region.endpoint})")
      end
      !result.empty?
    end

    # Create a consolidated instance.
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::ConsolidatedStack instance
    def consolidated(stack_prefix)
      aws_clients = {
        CloudFormationClient: @aws[:CloudFormationClient],
        CloudWatchClient: @aws[:CloudWatchClient],
        CloudWatchLogsClient: @aws[:CloudWatchLogsClient],
        Ec2Resource: @aws[:Ec2Resource]
      }

      RubyAemAws::ConsolidatedStack.new(stack_prefix, aws_clients)
    end

    # Create a full set instance.
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::FullSetStack instance
    def full_set(stack_prefix)
      aws_clients = {
        AutoScalingClient: @aws[:AutoScalingClient],
        CloudFormationClient: @aws[:CloudFormationClient],
        CloudWatchClient: @aws[:CloudWatchClient],
        CloudWatchLogsClient: @aws[:CloudWatchLogsClient],
        Ec2Resource: @aws[:Ec2Resource],
        ElbClient: @aws[:ElbClient]
      }

      RubyAemAws::FullSetStack.new(stack_prefix, aws_clients)
    end

    # Create Stack Manager resources
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::StackManager instance
    def stack_manager(stack_prefix)
      aws_clients = {
        CloudFormationClient: @aws[:CloudFormationClient],
        CloudWatchClient: @aws[:CloudWatchClient],
        CloudWatchLogsClient: @aws[:CloudWatchLogsClient],
        DynamoDBClient: @aws[:DynamoDBClient],
        S3Client: @aws[:S3Client],
        S3Resource: @aws[:S3Resource]
      }

      RubyAemAws::StackManager.new(stack_prefix, aws_clients)
    end
  end

  # Encapsulate AWS class creation for mocking.
  class AwsCreator
    def self.create_aws
      {
        Ec2Client: Aws::EC2::Client.new,
        Ec2Resource: Aws::EC2::Resource.new,
        ElbClient: Aws::ElasticLoadBalancingV2::Client.new(
          retry_limit: 20
        ),
        AutoScalingClient: Aws::AutoScaling::Client.new(
          retry_limit: 20
        ),
        CloudFormationClient: Aws::CloudFormation::Client.new,
        CloudWatchClient: Aws::CloudWatch::Client.new(
          retry_limit: 20
        ),
        CloudWatchLogsClient: Aws::CloudWatchLogs::Client.new(
          retry_limit: 20
        ),
        DynamoDBClient: Aws::DynamoDB::Client.new,
        S3Client: Aws::S3::Client.new,
        S3Resource: Aws::S3::Resource.new
      }
    end
  end
end
