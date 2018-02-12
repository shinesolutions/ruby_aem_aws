require_relative 'mixins/sns_topic'
require_relative 'mixins/dynamo_db'

module RubyAemAws
  module Component
    # Interface to the AWS StackManager to send out commands
    class StackManagerTest
      include DynamoDB
      include SNSTopic
      # @param topicarn AWS SNS-Topic ARN
      # @param stack_prefix AEM Stack-Prefix

      def initialize(topicarn, stack_prefix, dyndb_table_name)
        @topicarn = topicarn
        @stack_prefix = stack_prefix
        @dyndb_table = dyndb_table_name

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
      # @param task AWS SSM run_cmd
      # @param details SNS Message details
      # @return Command state

      def check(task, parameters, retry_opts)
        message_id = sns_publish(@topicarn, task, @stack_prefix, parameters)

        with_retries(retry_opts) do
          @cmd_id = dyn_db_scan(@scan_map, @dyndb_table, message_id)
        end

        with_retries(retry_opts) do
          @state = dyn_db_query(@query_map, @dyndb_table, @cmd_id)
        end

        if @state == 'Success'
          return TRUE
        elsif @state == 'Failed'
          return FALSE
        end
      end
      def sns_publish(topicarn, task, stack_prefix, details)
        details = JSON.generate(details).tr('\"', '\'')
        sns_message = "{ \"default\": \"{ 'task': '#{task}', 'stack_prefix': '#{stack_prefix}', 'details': #{details} }\"}"
        publish(topicarn, sns_message)
      end
      def dyn_db_scan(scan_map, dyndb_table, attribute_value)
        scan(scan_map, dyndb_table, attribute_value).items[0]['command_id']
      end
      def dyn_db_query(query_map, dyndb_table, key_attribute_value)
        query(query_map, dyndb_table, key_attribute_value).items[0]['state']
      end
    end
  end
end
