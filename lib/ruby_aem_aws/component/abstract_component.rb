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

require_relative 'component_descriptor'

module RubyAemAws
  # Add common methods to all Components.
  module AbstractComponent
    include Component

    def to_s
      "#{self.class.name.split('::').last}(#{@descriptor.stack_prefix unless @descriptor.nil?})"
    end

    def get_all_instances
      ec2_resource.instances(filter_for_descriptor)
    end

    def get_instance_by_id(instance_id)
      ec2_resource.instance(instance_id)
    end

    # def get_first_instance
    #   instances = ec2_resource.instances(filter_for_descriptor)
    #   count = instances.count
    #   raise "Expected exactly one instance but got #{count} for #{descriptor.stack_prefix}, #{descriptor.ec2.component}, #{descriptor.ec2.name}" if count != 1
    #   instances.first
    # end

    def get_num_of_instances
      get_all_instances.entries.length
    end

    def get_random_instance
      get_all_instances.entries.sample
    end

    private

    def filter_for_descriptor
      {
        filters: [
          { name: 'tag:StackPrefix', values: [descriptor.stack_prefix] },
          { name: 'tag:Component', values: [descriptor.ec2.component] },
          { name: 'tag:Name', values: [descriptor.ec2.name] },
          { name: 'instance-state-name', values: InstanceState::ALL_ACTIVE }
        ]
      }
    end
  end
end
