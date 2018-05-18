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
  # Add common methods to StackManager resource
  module AbstractStackManager
    private def filter_for_db_scan(dynamodb_tablename, attribute_value)
      {
        table_name: dynamodb_tablename,
        attributes_to_get: ['command_id'],
        scan_filter: {
          'message_id' => {
            attribute_value_list: [attribute_value],
            comparison_operator: 'EQ'
          }
        },
        consistent_read: true
      }
    end

    private def filter_for_db_query(dynamodb_tablename, key_attribute_value)
      {
        table_name: dynamodb_tablename,
        consistent_read: true,
        attributes_to_get: ['state'],
        key_conditions: {
          'command_id' => {
            attribute_value_list: [key_attribute_value],
            comparison_operator: 'EQ'
          }
        },
        query_filter: {
          'state' => {
            attribute_value_list: ['Pending'],
            comparison_operator: 'NE'
          }
        }
      }
    end

    private def message_for_sns_publish(task, stack_prefix, details)
      "{ \"default\": \"{ 'task': '#{task}', 'stack_prefix': '#{stack_prefix}', 'details': #{details} }\"}"
    end
  end
end
