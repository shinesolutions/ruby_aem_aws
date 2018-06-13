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

require_relative '../component/component_descriptor'
require_relative '../mixins/instance_describer'
require_relative '../error'

module RubyAemAws
  # Add common methods to all Components.
  module AbstractComponent
    include Component
    include InstanceDescriber

    def to_s
      "#{self.class.name.split('::').last}(#{@descriptor.stack_prefix unless @descriptor.nil?})"
    end

    private

    def filter_for_descriptor
      {
        filters: [
          { name: 'tag:StackPrefix', values: [@descriptor.stack_prefix] },
          { name: 'tag:Component', values: [@descriptor.ec2.component] },
          { name: 'tag:Name', values: [@descriptor.ec2.name] },
          { name: 'instance-state-name', values: ['running'] }
        ]
      }
    end

    # @param snapshot_type SnapshotType tag
    # @return Array of a EC2 filter to filter for a specific Snapshottype
    def filter_for_snapshot(snapshot_type)
      {
        filters: [
          { name: 'tag:StackPrefix', values: [@descriptor.stack_prefix] },
          { name: 'tag:SnapshotType', values: [snapshot_type] },
          { name: 'tag:Component', values: [@descriptor.ec2.component] }
        ]
      }
    end
  end
end
