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
      # Initialise response as an empty response having no events and no next token
      # This is needed to handle the scenario when initial filter log events returns
      # a response with nil next token, ensuring the clients of this method to
      # be able to identify any empty response events.
      response = { events: [], next_token: nil }

      filter = filter_for_cloudwatch_log_event(loggroup_name, log_stream_name, log_message)
      curr_response = cloud_watch_log_client.filter_log_events(filter)

      # Since late 2021 (circa aws-sdk-cloudwatchlog 1.45.0), the last response
      # is always empty (empty response events and nil next token).
      # Previous to late 2021, the last response used to contain the filtered events
      # with nil next token.
      until curr_response.next_token.nil?
        next_token = { next_token: curr_response.next_token }
        filter.update(next_token)
        response = curr_response
        curr_response = cloud_watch_log_client.filter_log_events(filter)
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
