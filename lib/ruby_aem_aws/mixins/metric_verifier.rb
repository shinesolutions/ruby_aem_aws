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

    def component_alarm?(alarm_name)
      alarm?(alarm_name)
    end

    # @param metric_name Cloudwatch metric name
    # @return True if all component instances have the CW metric
    def component_metric?(namespace, metric_name)
      dimensions_name = 'FixedDimension'
      dimensions_value = "#{@descriptor.stack_prefix_in}-#{@descriptor.ec2.component}"
      response = metric?(namespace, metric_name, dimensions_name, dimensions_value)
      return true if response.eql? true
    end

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

    # @param logfile_name name of the logfile of the log stream
    # @return True if all component have the log stream
    def component_log_event?(logfile_name, log_message)
      instances_with_log_stream = []
      loggroup_name = "#{@descriptor.stack_prefix_in}#{logfile_name}"

      instances = get_all_instances
      instances_found = instances.count

      instances.each do |instance|
        next if instance.nil?
        instance_id = instance.instance_id
        log_stream_name = "#{@descriptor.ec2.component}/#{instance_id}"

        response = log_event?(loggroup_name, log_stream_name, log_message)

        instances_with_log_stream.push(instance_id) if response.eql? true
      end
      instances_with_log_stream = instances_with_log_stream.count

      return true unless instances_with_log_stream < instances_found
    end

    # @param logfile_name name of the logfile of the loggroup
    # @return True if loggroup exists
    def component_loggroup?(logfile_name)
      loggroup_name = "#{@descriptor.stack_prefix_in}#{logfile_name}"

      response = loggroup?(loggroup_name)

      return true if response.eql? true
    end

    # @param logfile_name name of the logfile of the log stream
    # @return True if all component have the log stream
    def component_log_stream?(logfile_name)
      instances_with_log_stream = []
      loggroup_name = "#{@descriptor.stack_prefix_in}#{logfile_name}"

      instances = get_all_instances
      instances_found = instances.count

      instances.each do |instance|
        next if instance.nil?
        instance_id = instance.instance_id
        log_stream_name = "#{@descriptor.ec2.component}/#{instance_id}"

        response = log_stream?(loggroup_name, log_stream_name)

        instances_with_log_stream.push(instance_id) if response.eql? true
      end
      instances_with_log_stream = instances_with_log_stream.count

      return true unless instances_with_log_stream < instances_found
    end

    # @param alarm_name name of the Cloudwatch alarm
    # @return True if Cloudwatch alarm exist
    def alarm?(alarm_name)
      response = get_alarm(alarm_name)

      return true unless response.metric_alarms.empty?
    end

    def metric?(namespace, metric_name, dimensions_name, dimensions_value)
      dimension_values = dimensions_value_filter_for_cloudwatch_metric(dimensions_name, dimensions_value)
      dimension_filter = dimensions_filter_for_cloudwatch_metric(dimension_values)

      response = get_metrics(namespace, metric_name, dimension_filter)

      return true unless response.metrics.empty?
    end

    # @param logfile_name name of the logfile of the log stream
    # @return True if all component have the log stream
    def log_stream?(loggroup_name, logfile_name)
      response = loggroup?(loggroup_name)
      return false unless response.eql? true

      response = get_log_streams(loggroup_name, logfile_name)

      return true unless response.log_streams.empty?
    end

    # @param logfile_name name of the logfile of the log stream
    # @return True if all component have the log stream
    def log_event?(loggroup_name, logfile_name, log_message)
      response = loggroup?(loggroup_name)
      return false unless response.eql? true

      response = log_stream?(loggroup_name, logfile_name)
      return false unless response.eql? true

      response = get_log_event(loggroup_name, logfile_name, log_message)
      return true unless response.events.empty?
    end

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
  end
end
