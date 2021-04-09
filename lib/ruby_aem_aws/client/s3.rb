# Copyright 2018-2021 Shine Solutions Group
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

module RubyAemAws
  # Mixin for interaction with AWS S3
  module S3Access
    # @param bucket AWS S3 bucket name
    # @return AWS S3 resource bucket connection
    def get_s3_bucket(bucket)
      s3_resource.bucket(bucket)
    end

    # @param bucket AWS S3 bucket name
    # @param s3_object_name AWS S3 object name
    # @return S3 object
    def get_s3_bucket_object(bucket, s3_object_name)
      bucket = get_s3_bucket(bucket)
      bucket.object(s3_object_name)
    end

    # @param bucket AWS S3 bucket name
    # @param s3_object_name AWS S3 object name
    # @param dest_path Download destionation path
    # @return S3 object
    def get_s3_object(bucket, s3_object_name, dest_path)
      options = { bucket: bucket, key: s3_object_name }
      options = options.merge(response_target: dest_path) unless dest_path.nil?
      s3_client.get_object(options)
    end
  end
end
