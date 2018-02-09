require_relative 'mixins/sns_topic'
require_relative 'mixins/dynamo_db'

module RubyAemAws
  module Component
    # Interface to the AWS StackManager to send out commands
    class StackManagerTest
      include DynamoDB
      include SNSTopic

      def initialize(topicarn, stack_prefix)
        @topicarn = topicarn
        @stack_prefix = stack_prefix
        @retry_opts = { max_tries: 5,
                        base_sleep_seconds: 5.0,
                        max_sleep_seconds: 15.5 }
        super("#{@stack_prefix}-AemStackManagerTable", 'command_id', 'EQ')
      end
      # @param task AWS SSM run_cmd
      # @param details SNS Message details
      # @return Command state

      def check(task, parameters)
        details = JSON.generate(parameters).tr('\"', '\'')
        sns_message = "{ \"default\": \"{ 'task': '#{task}', 'stack_prefix': '#{@stack_prefix}', 'details': #{details} }\"}"
        message_id = publish(@topicarn, sns_message)

        with_retries(@retry_opts) do
          @cmd_id = scan('command_id', 'message_id', message_id, 'EQ').items[0]['command_id']
        end

        with_retries(@retry_opts) do
          query('state', @cmd_id, 'state', 'Pending', 'NE').items[0]['state']
        end
      end
    end
  end
end
