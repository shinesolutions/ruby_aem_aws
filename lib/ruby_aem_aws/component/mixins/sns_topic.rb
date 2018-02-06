require 'aws-sdk-sns'

module RubyAemAws
	module SNSTopic
		# @param topicarn the ARN of the SNS Topix to publish the message
                # @param sns_message the SNS Message to publish
		# @return Message ID
		def publish(topicarn, sns_message)
			client = Aws::SNS::Topic.new(topicarn)
			publish = client.publish({
                                subject: "Publish",
                                message: sns_message,
                                message_structure: "json",
                        })
			publish.message_id
		end
	end
end
