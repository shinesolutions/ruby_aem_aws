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

require_relative '../abstract/cloudwatch'
require_relative '../client/cloudwatch'

module RubyAemAws
  # Mixin for checking that an instance has associated CloudWatch metrics.
  module MetricVerifier
    include CloudwatchClient
    include AbstractCloudwatch

    # @param alarm_name name of the Cloudwatch alarm
    # @return True if Cloudwatch alarm exists for component
    def component_alarm?(alarm_name)
      alarm?(alarm_name)
    end

    # @param namespace Cloudwatch metric namespace
    # @param metric_name Cloudwatch metric name
    # @return True if Cloudwatch metric exists for component
    def component_metric?(namespace, metric_name)
      dimensions_name = 'FixedDimension'
      dimensions_value = "#{@descriptor.stack_prefix_in}-#{@descriptor.ec2.component}"
      response = metric?(namespace, metric_name, dimensions_name, dimensions_value)
      return true if response.eql? true
    end

    # @param metric_name Cloudwatch EC2 metric name
    # @return True if Cloudwatch EC2 metric exists for all component instances
    def component_ec2_metric?(metric_name)
      namespace = 'AWS/EC2'
      dimensions_name = 'InstanceId'
      instances_with_metric = []
      instances = get_all_instances
      instances_found = instances.count

      instances.each do |instance|
        next if instance.nil?

        instance_id = instance.instance_id
        dimensions_value = instance.instance_id

        response = metric?(namespace, metric_name, dimensions_name, dimensions_value)

        instances_with_metric.push(instance_id) if response.eql? true
      end

      instances_with_metric = instances_with_metric.count

      return true unless instances_with_metric < instances_found
    end

    # @param log_file_name Name of the log file available on Cloudwatch
    # @param log_message name of the logfile of the log stream
    # @return True if log message exists in Cloudwatch log stream for all component instances
    def component_log_event?(log_file_name, log_message)
      instances_with_log_event = []
      loggroup_name = "#{@descriptor.stack_prefix_in}#{log_file_name}"

      instances = get_all_instances
      instances_found = instances.count

      instances.each do |instance|
        next if instance.nil?

        # @instance_id is needed by method _get_log_stream_name
        @instance_id = instance.instance_id
        response = log_event?(loggroup_name, log_message)

        next unless response.eql? true

        instance_id = instance.instance_id
        instances_with_log_event.push(instance_id)
      end
      instances_with_log_event = instances_with_log_event.count

      return true unless instances_with_log_event < instances_found
    end

    # @param log_file_name Name of the log file available on Cloudwatch
    # @return True if Cloudwatch loggroup exists for component
    def component_loggroup?(log_file_name)
      loggroup_name = "#{@descriptor.stack_prefix_in}#{log_file_name}"

      response = loggroup?(loggroup_name)

      return true if response.eql? true
    end

    # @param log_file_name Name of the log file available on Cloudwatch
    # @return True if Cloudwatch log stream exists for all component instances
    def component_log_stream?(log_file_name)
      log_streams_found = []
      loggroup_name = "#{@descriptor.stack_prefix_in}#{log_file_name}"

      instances = get_all_instances
      instances_found = instances.count

      instances.each do |instance|
        next if instance.nil?

        # @instance_id is needed by method _get_log_stream_name
        @instance_id = instance.instance_id
        log_stream_name = _get_log_stream_name(loggroup_name)

        next if log_stream_name.eql? nil

        log_streams_found.push(log_stream_name)
      end
      log_streams_found = log_streams_found.count

      return true unless log_streams_found < instances_found
    end

    # @param alarm_name name of the Cloudwatch alarm
    # @return True if Cloudwatch alarm exists
    def alarm?(alarm_name)
      response = get_alarm(alarm_name)

      return true unless response.metric_alarms.empty?
    end

    # @param namespace Cloudwatch metric namespace
    # @param metric_name Cloudwatch metric name
    # @param dimensions_name Cloudwatch metric dimension name
    # @param dimensions_value Cloudwatch metric dimension value
    # @return True if Cloudwatch metric exists
    def metric?(namespace, metric_name, dimensions_name, dimensions_value)
      dimension_values = dimensions_value_filter_for_cloudwatch_metric(dimensions_name, dimensions_value)
      dimension_filter = dimensions_filter_for_cloudwatch_metric(dimension_values)

      response = get_metrics(namespace, metric_name, dimension_filter)

      return true unless response.metrics.empty?
    end

    # @param loggroup_name Cloudwatch loggroup name
    # @return True if Cloudwatch log stream exists
    def log_stream?(loggroup_name, log_stream_name)
      response = loggroup?(loggroup_name)
      return false unless response.eql? true

      response = get_log_streams(loggroup_name, log_stream_name)

      return true unless response.log_streams.empty?
    end

    # @param loggroup_name Cloudwatch loggroup name
    # @param log_message name of the logfile of the log stream
    # @return True if Cloudwatch log event exists
    def log_event?(loggroup_name, log_message)
      response = loggroup?(loggroup_name)
      return false unless response.eql? true

      log_stream_name = _get_log_stream_name(loggroup_name)

      response = get_log_event(loggroup_name, log_stream_name, log_message)
      return true unless response.events.empty?
    end

    # @param loggroup Cloudwatch loggroup name
    # @return True if Cloudwatch loggroup exists
    def loggroup?(loggroup_name)
      namespace = 'AWS/Logs'
      metric_name = 'IncomingLogEvents'
      dimensions_name = 'LogGroupName'
      dimensions_value = loggroup_name

      dimension_values = dimensions_value_filter_for_cloudwatch_metric(dimensions_name, dimensions_value)
      dimension_filter = dimensions_filter_for_cloudwatch_metric(dimension_values)

      response = get_metrics(namespace, metric_name, dimension_filter)

      return true unless response.metrics.empty?
    end

    def _get_log_stream_name(loggroup_name)
      # Get Logstream name by instance_id
      log_stream_name_instance_id = "#{@descriptor.ec2.component}/#{@instance_id}"
      response = log_stream?(loggroup_name, log_stream_name_instance_id)

      return log_stream_name_instance_id if response.eql? true

      # Get Logstream name by ec2 hostname
      ec2_hostname = Socket.gethostname
      log_stream_name_hostname = "#{@descriptor.ec2.component}/#{ec2_hostname}"
      response = log_stream?(loggroup_name, log_stream_name_hostname) unless response.eql? true

      return log_stream_name_hostname if response.eql? true
    end
  end
end
