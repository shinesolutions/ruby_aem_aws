require_relative 'component/stack_manager_resources'

module RubyAemAws
  # Interface to the AWS StackManager to send out commands
  class StackManager
    # @param topicarn AWS SNS-Topic ARN
    # @param stack_prefix AEM Stack-Prefix
    # @param ec2_client AWS EC2 Client connection
    # @param dynamodb_client AWS DynamoDB Client connection
    # @param s3_client AWS S# Client connection
    def initialize(stack_prefix, topicarn, ec2_client, dynamodb_client, s3_client)
      @stack_prefix = stack_prefix
      @topicarn = topicarn
      @sm_resources = RubyAemAws::Component::StackManagerResources.new(dynamodb_client, ec2_client, s3_client)
    end

    # @param task AWS SSM run_cmd
    # @param parameters SNS Message details
    # @param dyndb_table_name AEM StackManager DynamoDB table name
    # @param scan_retry_opts Retry option for scan operation
    # @param query_retry_opts Retry option for query operation
    # @return true/false
    def check(task, parameters, dyndb_table_name, scan_retry_opts, query_retry_opts)
      message_id = @sm_resources.sns_publish(@topicarn, task, @stack_prefix, parameters)

      with_retries(scan_retry_opts) do
        @cmd_id = @sm_resources.dyn_db_msg_scan(dyndb_table_name, message_id)
      end

      with_retries(query_retry_opts) do
        @state = @sm_resources.dyn_db_cmd_query(dyndb_table_name, @cmd_id)
      end

      return TRUE unless @state.eql? 'Failed'
    end

    # @param stack_prefix AEM Stack-Prefix
    # @param snapshot_type Snapshot type
    # @param component AEM component name
    # @return AWS Snapshost list
    def ec2_snapshot_search(stack_prefix, snapshot_type, component)
      @sm_resources.snap_search(stack_prefix, snapshot_type, component)
    end

    # @param s3_bucket_name S3 bucketname
    # @param s3_object_name S3 Object name
    # @param dest_path local download path
    # @return s3 objec
    def s3_download(s3_bucket_name, s3_object_name, dest_path)
      @sm_resources.s3_download_object(s3_bucket_name, s3_object_name, dest_path)
    end
  end
end
