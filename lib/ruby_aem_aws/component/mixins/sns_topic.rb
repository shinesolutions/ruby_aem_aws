module RubyAemAws
  # AWS Interface publish to SNS-Topic
  module SNSTopic
    # @param topicarn the ARN of the SNS Topix to publish the message
    # @param sns_message the SNS Message to publish
    # @return Message ID
    def publish(topicarn, sns_message)
      client = Aws::SNS::Topic.new(topicarn)
      sns_message = { subject: 'Publish',
                      message: sns_message,
                      message_structure: 'json' }
      publish = client.publish(sns_message)
      publish.message_id
    end
  end
end
