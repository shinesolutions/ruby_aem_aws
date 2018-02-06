require_relative 'mixins/sns_topic'
require_relative 'mixins/dynamo_db'

module RubyAemAws
	module Component
		class StackManagerTest
			include DynamoDB
			include SNSTopic

			def initialize(topicarn, stack_prefix)
				@topicarn = topicarn
				@stack_prefix = stack_prefix
				@retry_opts = {:max_tries => 5,
					:base_sleep_seconds => 3.0,
					:max_sleep_seconds => 15.5
				}
			end
			# @param task AWS SSM run_cmd
			# @param details SNS Message details
			# @return Command state
			def check(task, details)
				sns_message = "{ \"default\": \"{ 'task': '#{task}', 'stack_prefix': '#{@stack_prefix}', 'details': { #{details} }}\"}"
				message_id = publish(@topicarn, sns_message)

				with_retries(@retry_opts) do
					@cmd_id = scan("#{@stack_prefix}-AemStackManagerTable", 'command_id', 'message_id', message_id, 'EQ').items[0]['command_id']
		  	end

				with_retries(@retry_opts) do
					state = query("#{@stack_prefix}-AemStackManagerTable", 'state', 'command_id', @cmd_id, 'EQ', 'state', 'Pending', 'NE').items[0]['state']
					puts "Task execution: #{state}"
				end
			end
		end
	end
end
