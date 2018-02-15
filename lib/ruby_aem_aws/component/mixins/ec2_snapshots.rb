module RubyAemAws
  # AWS Interface publish to SNS-Topic
  module EC2Snapshot
    # @param topicarn the ARN of the SNS Topix to publish the message
    # @param sns_message the SNS Message to publish
    # @return Message ID
    def snapshot_search(stack_prefix, snapshot_type, component, ec2_client)
      ec2_client.describe_snapshots(filters: [
                                      {
                                        name: 'tag:StackPrefix',
                                        values: [
                                          stack_prefix
                                        ]
                                      }, {
                                        name: 'tag:SnapshotType',
                                        values: [
                                          snapshot_type
                                        ]
                                      }, {
                                        name: 'tag:Component',
                                        values: [
                                          component
                                        ]
                                      }
                                    ])
    end
  end
end
