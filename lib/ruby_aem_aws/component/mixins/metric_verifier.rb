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
  module MetricVerifier
    # @param _name the name of the metric to check for.
    # @return true if the instance has a metric with @name.
    def metric?(_name)
      # TODO: complete this method.
      # instances = ec2_resource.instances(
      #   filters: [
      #     { name: 'tag:StackPrefix', values: [descriptor.stack_prefix] },
      #     { name: 'tag:Component', values: [descriptor.ec2.component] },
      #     { name: 'tag:Name', values: [descriptor.ec2.name] }
      #   ]
      # )
      # raise 'Couldn\'t find Author instance' if instances.length != 1
      # instance = instances[0]
      # puts("Found instance: #{instance}")
      #
      # metrics = @cloud_watch_client.list_metrics(
      #   namespace: 'AWS/EC2',
      #   metric_name: name,
      #   dimensions:
      #     {
      #       name: 'InstanceID',
      #       value: instance.instance_id
      #     }
      # ).metrics
      # puts("Metrics: #{metrics}")
      # !metrics.empty?
      true
    end
  end
end
