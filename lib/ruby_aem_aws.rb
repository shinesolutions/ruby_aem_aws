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

require_relative 'ruby_aem_aws/consolidated_stack'
require_relative 'ruby_aem_aws/full_set_stack'
require_relative 'ruby_aem_aws/stack_manager'

module RubyAemAws
  # AemAws class represents the AWS stack for AEM.
  class AemAws
    # @param conf configuration hash of the following configuration values:
    # - region: the AWS region (eg ap-southeast-2)
    # - aws_access_key_id: the AWS access key
    # - aws_secret_access_key: the AWS secret access key
    # - aws_profile: AWS profile name
    # @return new RubyAemAws::AemAws instance
    def initialize(conf = {})
      conf[:region] ||= Constants::REGION_DEFAULT
      conf[:aws_access_key_id] ||= Constants::ACCESS_KEY_ID
      conf[:aws_secret_access_key] ||= Constants::SECRET_ACCESS_KEY
      conf[:aws_profile] ||= Constants::PROFILE

      Aws.config.update(region: conf[:region])

      credentials = Aws::Credentials.new(conf[:aws_access_key_id], conf[:aws_secret_access_key]) unless conf[:aws_access_key_id].nil?
      credentials = Aws::SharedCredentials.new(profile_name: conf[:aws_profile]) unless conf[:aws_profile].nil?
      credentials = Aws::InstanceProfileCredentials.new if conf[:aws_profile].nil? && conf[:aws_access_key_id].nil?
      raise RubyAemAws::ArgumentError unless defined? credentials
      Aws.config.update(credentials: credentials)

      aws = AwsCreator.create_aws
      @ec2_client = aws[:Ec2Client]
      @ec2_resource = aws[:Ec2Resource]
      @elb_client = aws[:ElbClient]
      @auto_scaling_client = aws[:AutoScalingClient]
      # The V2 API only supports Application ELBs, and we currently use Classic.
      # @elb_client = Aws::ElasticLoadBalancingV2::Client.new(region: conf[:region])
      @cloud_watch_client = aws[:CloudWatchClient]
      @dynamodb_client = aws[:DynamoDBClient]
      @s3_client = aws[:S3Client]
      @s3_resource = aws[:S3Resource]
    end

    # Test connection to Amazon AWS
    #
    # @return One or more regions that are currently available.
    def test_connection
      result = []
      @ec2_client.describe_regions.regions.each do |region|
        result.push("Region #{region.region_name} (#{region.endpoint})")
      end
      !result.empty?
    end

    # Create a consolidated instance.
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::ConsolidatedStack instance
    def consolidated(stack_prefix)
      RubyAemAws::ConsolidatedStack.new(stack_prefix, @ec2_resource, @cloud_watch_client)
    end

    # Create a full set instance.
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::FullSetStack instance
    def full_set(stack_prefix)
      RubyAemAws::FullSetStack.new(stack_prefix, @ec2_resource, @elb_client, @auto_scaling_client, @cloud_watch_client)
    end

    # Create Stack Manager resources
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::StackManager instance
    def stack_manager(stack_prefix)
      RubyAemAws::StackManager.new(stack_prefix, @dynamodb_client, @s3_client, @s3_resource)
    end
  end

  # Encapsulate AWS class creation for mocking.
  class AwsCreator
    def self.create_aws
      {
        Ec2Client: Aws::EC2::Client.new,
        Ec2Resource: Aws::EC2::Resource.new,
        ElbClient: Aws::ElasticLoadBalancing::Client.new(retry_limit: 16, retry_backoff: lambda{|c| sleep 60 }),
        AutoScalingClient: Aws::AutoScaling::Client.new(retry_limit: 16, retry_backoff: lambda{|c| sleep 60 }),
        CloudWatchClient: Aws::CloudWatch::Client.new,
        DynamoDBClient: Aws::DynamoDB::Client.new,
        S3Client: Aws::S3::Client.new,
        S3Resource: Aws::S3::Resource.new
      }
    end
  end
end
