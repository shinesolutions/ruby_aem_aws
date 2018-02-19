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

require_relative 'abstract_stackmanager'
require_relative 'mixins/sns_topic'
require_relative 'mixins/dynamo_db'
require_relative 'mixins/s3'

module RubyAemAws
  module Component
    # Interface to the AWS StackManager to send out commands
    class StackManagerResources
      attr_reader :dynamodb_client, :s3_client, :s3_resource
      include AbstractStackManager
      include DynamoDB
      include SNSTopic
      include S3Access

      # @param dynamodb_client AWS DynamoDB client connection
      # @param s3_client AWS S3 client connection
      # @param s3_resource AWS S3 client connection
      # @return new RubyAemAws::StackManager::StackManagerResources
      def initialize(dynamodb_client, s3_client, s3_resource)
        @dynamodb_client = dynamodb_client
        @s3_client = s3_client
        @s3_resource = s3_resource
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
