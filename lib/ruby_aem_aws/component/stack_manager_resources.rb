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

require_relative '../abstract/stackmanager'
require_relative '../client/sns_topic'
require_relative '../client/dynamo_db'
require_relative '../client/s3'
require_relative '../mixins/metric_verifier'

module RubyAemAws
  module Component
    # Interface to the AWS StackManager to send out commands
    class StackManagerResources
      attr_reader :dynamodb_client, :s3_client, :s3_resource, :cloud_watch_client, :cloud_watch_log_client

      include AbstractStackManager
      include DynamoDB
      include MetricVerifier
      include SNSTopic
      include S3Access

      # @param params Array of AWS Clients and Resource connections:
      # - CloudWatchClient: AWS Cloudwatch Client.
      # - CloudWatchLogsClient: AWS Cloudwatch Logs Client.
      # - DynamoDBClient: AWS DynamoDB Client.
      # - S3Client: AWS S3 Client.
      # - S3Resource: AWS S3 Resource connection.
      # @return new RubyAemAws::StackManager::StackManagerResources
      def initialize(params)
        @dynamodb_client = params[:DynamoDBClient]
        @s3_client = params[:S3Client]
        @s3_resource = params[:S3Resource]
        @cloud_watch_client = params[:CloudWatchLogsClient]
        @cloud_watch_log_client = params[:CloudWatchLogsClient]
      end

      # @param topicarn AWS SNS-Topic ARN
      # @param task AEM StackManager task
      # @param stack_prefix AEM Stack-Prefix
      # @param details AEM StackManager task detail message
      # @return AWS SNS publish message id
      def sns_publish(topicarn, task, stack_prefix, details)
        details = JSON.generate(details).tr('\"', '\'')
        publish(topicarn, message_for_sns_publish(task, stack_prefix, details))
      end

      # @param dynamodb_tablename AWS DynamoDB table name
      # @param attribute_value Attribute value to scan for
      # @return Scan result
      def dyn_db_msg_scan(dynamodb_tablename, attribute_value)
        scan(filter_for_db_scan(dynamodb_tablename, attribute_value))
      end

      # @param dynamodb_tablename AWS DynamoDB table name
      # @param attribute_value Attribute value to query for
      # @return Command state
      def dyn_db_cmd_query(dynamodb_tablename, attribute_value)
        key_attribute_value = attribute_value.items[0]['command_id']
        state = query(filter_for_db_query(dynamodb_tablename, key_attribute_value))
        state.items[0]['state']
      end

      # @param s3_bucket_name S3 bucketname
      # @param s3_object_name S3 Object name
      # @return AWS S3 resource object
      def s3_resource_object(s3_bucket_name, s3_object_name)
        get_s3_bucket_object(s3_bucket_name, s3_object_name)
      end

      # @param s3_bucket_name S3 bucketname
      # @param s3_object_name S3 Object name
      # @param dest_path local download path, default: nil
      # @return AWS S3 client object
      def s3_download_object(s3_bucket_name, s3_object_name, dest_path = nil)
        get_s3_object(s3_bucket_name, s3_object_name, dest_path)
      end
    end
  end
end
