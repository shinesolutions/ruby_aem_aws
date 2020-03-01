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
    private

    # @param alarm_name Cloudwatch alarm name
    # @return Array of a Cloudwatch alarm filter to filter for a specific Cloudwatch alarm
    def filter_for_cloudwatch_alarm(alarm_name)
      {
        alarm_names: [alarm_name]
      }
    end

    # @param loggroup_name Cloudwatch loggroup name
    # @param log_stream_name Cloudwatch logstream name
    # @param log_message log message to filter for
    # @return Array of a Cloudwatch log event filter to filter for a specific Cloudwatch log event
    def filter_for_cloudwatch_log_event(loggroup_name, log_stream_name, log_message)
      {
        log_group_name: loggroup_name,
        log_stream_names: [log_stream_name],
        filter_pattern: log_message
      }
    end

    # @param log_group_name Cloudwatch loggroup name
    # @param log_stream_name Cloudwatch logstream name
    # @return Array of a Cloudwatch log stream filter to filter for a specific Cloudwatch log stream
    def filter_for_cloudwatch_log_stream(log_group_name, log_stream_name)
      {
        log_group_name: log_group_name,
        log_stream_name_prefix: log_stream_name,
        order_by: 'LogStreamName'
      }
    end

    # @param namespace Cloudwatch metric namespace
    # @param metric_name Cloudwatch metric name
    # @return Array of a Cloudwatch metric filter to filter for a specific Cloudwatch metric
    def filter_for_cloudwatch_metric(namespace, metric_name)
      {
        namespace: namespace,
        metric_name: metric_name
      }
    end

    # @param dimension_values Cloudwatch Dimension value
    # @return Array of a Cloudwatch dimension filter for the Cloudwatch metric filter
    def dimensions_filter_for_cloudwatch_metric(dimension_values)
      {
        dimensions: [
          dimension_values
        ]
      }
    end

    # @param dimensions_name Cloudwatch Dimension name
    # @param dimensions_value Cloudwatch Dimension value
    # @return Array of a Cloudwatch Dimension value filter for the Cloudwatch dimension filter
    def dimensions_value_filter_for_cloudwatch_metric(dimensions_name, dimensions_value)
      {
        name: dimensions_name,
        value: dimensions_value
      }
    end
  end
end
