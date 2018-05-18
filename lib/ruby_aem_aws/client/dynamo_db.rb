# Copyright 2018 Shine Solutions
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
  # Mixin for interaction with AWS DynamoDB
  module DynamoDB
    # @param filter Filter to scan for
    # @return scanned attribute
    def scan(filter)
      # We need to give AWS time to update the DynamoDB
      # consistent_read seems not to work everytime
      sleep 5
      dynamodb_client.scan(filter)
    end

    # @param filter Filter to query for
    # @return queried attribute
    def query(filter)
      # We need to give AWS time to update the DynamoDB
      # consistent_read seems not to work everytime
      sleep 5
      dynamodb_client.query(filter)
    end
  end
end
