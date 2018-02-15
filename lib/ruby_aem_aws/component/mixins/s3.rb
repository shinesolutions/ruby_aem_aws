module RubyAemAws
  # AWS Interface publish to SNS-Topic
  module S3Access
    # @param client AWS S3 Client connection
    # @param s3_bucket_name AWS S3 BUcketname
    # @return S3 Bucket connection
    def get_s3_bucket(client, s3_bucket_name)
      client.buckets[s3_bucket_name]
    end

    # @param s3_bucket AWS S3 Bucket connection
    # @param s3_object_name S3 object name
    # @return S3 object connection
    def get_s3_object(s3_bucket, s3_object_name)
      s3_bucket.objects[s3_object_name]
    end
  end
end
