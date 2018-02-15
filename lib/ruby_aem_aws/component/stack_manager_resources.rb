require_relative 'mixins/sns_topic'
require_relative 'mixins/dynamo_db'
require_relative 'mixins/ec2_snapshots'
require_relative 'mixins/s3'

module RubyAemAws
  module Component
    # Interface to the AWS StackManager to send out commands
    class StackManagerResources
      include DynamoDB
      include SNSTopic
      include EC2Snapshot
      include S3Access

      # @param topicarn AWS SNS-Topic ARN
      # @param stack_prefix AEM Stack-Prefix
      # @param dyndb_table_name AWS DynDB Table Name
      def initialize(dynamodb_client, ec2_client, s3_client)
        @ec2_client = ec2_client
        @dyndb_client = dynamodb_client
        @s3_client = s3_client

        @scan_map = { attributes_to_get: 'command_id',
                      attribute_filter: 'message_id',
                      attribute_operator: 'EQ' }

        @query_map = { attributes_to_get: 'state',
                       key_condition: 'command_id',
                       key_operator: 'EQ',
                       attribute_filter: 'state',
                       attribute_value: 'Pending',
                       attribute_operator: 'NE' }
      end

      # @param topicarn AWS SNS-Topic ARN
      # @param stack_prefix AEM Stack-Prefix
      # @param dyndb_table_name AWS DynDB Table Name
      def sns_publish(topicarn, task, stack_prefix, details)
        details = JSON.generate(details).tr('\"', '\'')
        sns_message = "{ \"default\": \"{ 'task': '#{task}', 'stack_prefix': '#{stack_prefix}', 'details': #{details} }\"}"
        publish(topicarn, sns_message)
      end

      # @param topicarn AWS SNS-Topic ARN
      # @param stack_prefix AEM Stack-Prefix
      # @param dyndb_table_name AWS DynDB Table Name
      def dyn_db_msg_scan(dyndb_table_name, attribute_value)
        scan(@scan_map, dyndb_table_name, attribute_value, @dyndb_client)
      end

      # @param topicarn AWS SNS-Topic ARN
      # @param stack_prefix AEM Stack-Prefix
      # @param dyndb_table_name AWS DynDB Table Name
      def dyn_db_cmd_query(dyndb_table_name, key_attribute_value)
        state = query(@query_map, dyndb_table_name, key_attribute_value.items[0]['command_id'], @dyndb_client)
        state.items[0]['state']
      end

      def snap_search(stack_prefix, snapshot_type, component)
        snapshot_search(stack_prefix, snapshot_type, component, @ec2_client)
      end

      def s3_download_object(s3_bucket_name, s3_object_name, dest_path)
        @s3_client.get_object(bucket: s3_bucket_name, key: s3_object_name, response_target: dest_path)
      end
    end
  end
end
