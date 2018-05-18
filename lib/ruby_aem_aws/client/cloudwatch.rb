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
  # Mixin for checking that an instance has associated CloudWatch metrics.
  module CloudwatchClient
    # @param alarm_name Cloudwatch alarm name
    # @return Cloudwatch client describe_alarms response
    def get_alarm(alarm_name)
      alarm_filter = filter_for_cloudwatch_alarm(alarm_name)

      response = cloud_watch_client.describe_alarms(alarm_filter)

      until response.next_token.nil?
        next_token = { next_token: response.next_token }
        filter.update(next_token)
        response = cloud_watch_client.describe_alarms(alarm_filter)
      end

      response
    end

    # @param loggroup_name Cloudwatch loggroup name
    # @param log_stream_name Cloudwatch log stream name
    # @param log_message Log message to filter for
    # @return Cloudwatch log client filter_log_events response
    def get_log_event(loggroup_name, log_stream_name, log_message)
      filter = filter_for_cloudwatch_log_event(loggroup_name, log_stream_name, log_message)
      response = cloud_watch_log_client.filter_log_events(filter)

      until response.next_token.nil?
        next_token = { next_token: response.next_token }
        filter.update(next_token)
        response = cloud_watch_client.filter_log_events(filter)
      end

      response
    end

    # @param loggroup_name Cloudwatch loggroup name
    # @param log_stream_name Cloudwatch log stream name
    # @return Cloudwatch log client describe_log_streams response
    def get_log_streams(loggroup_name, log_stream_name)
      filter = filter_for_cloudwatch_log_stream(loggroup_name, log_stream_name)

      response = cloud_watch_log_client.describe_log_streams(filter)

      until response.next_token.nil?
        next_token = { next_token: response.next_token }
        filter.update(next_token)
        response = cloud_watch_client.describe_log_streams(filter)
      end

      response
    end

    # @param namespace Cloudwatch namespace name
    # @param metric_name Cloudwatch metric name
    # @param dimension Cloudwatch dimension filter
    # @return Cloudwatch client list_metrics response
    def get_metrics(namespace, metric_name, dimension)
      filter = filter_for_cloudwatch_metric(namespace, metric_name)
      filter.update(dimension)

      response = cloud_watch_client.list_metrics(filter)

      until response.next_token.nil?
        next_token = { next_token: response.next_token }
        filter.update(next_token)
        response = cloud_watch_client.list_metrics(filter)
      end

      response
    end
  end
end
