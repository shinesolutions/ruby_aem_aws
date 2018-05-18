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

require_relative '../error'

module RubyAemAws
  # Add common methods to all Components.
  module AbstractCloudwatch
    private def filter_for_cloudwatch_alarm(alarm_name)
      {
        alarm_names: [alarm_name]
      }
    end

    private def filter_for_cloudwatch_log_event(loggroup_name, logfile_name, log_message)
      {
        log_group_name: loggroup_name,
        log_stream_names: [logfile_name],
        filter_pattern: log_message
      }
    end

    private def filter_for_cloudwatch_log_stream(log_group_name, log_stream_name)
      {
        log_group_name: log_group_name,
        log_stream_name_prefix: log_stream_name,
        order_by: 'LogStreamName'
      }
    end

    private def filter_for_cloudwatch_metric(namespace, metric_name)
      {
        namespace: namespace,
        metric_name: metric_name
      }
    end

    private def dimensions_filter_for_cloudwatch_metric(dimension_values)
      {
        dimensions: [
          dimension_values
        ]
      }
    end

    private def dimensions_value_filter_for_cloudwatch_metric(dimensions_name, dimensions_value)
      {
        name: dimensions_name,
        value: dimensions_value
      }
    end
  end
end
