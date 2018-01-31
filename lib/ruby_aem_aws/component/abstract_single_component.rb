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

require 'aws-sdk'
require_relative '../error'
require_relative 'abstract_component'

module RubyAemAws
  # Add common methods to all Components.
  module AbstractSingleComponent
    include AbstractComponent

    def get_instance
      instances = ec2_resource.instances(filter_for_descriptor)
      count = instances.count
      # raise RubyAemAws::ExpectedSingleInstanceError.new(count, descriptor) if count > 1
      raise RubyAemAws::ExpectedSingleInstanceError if count > 1
      return nil if instances.empty?
      instances.first
    end

    def get_all_instances
      [get_instance]
    end

    private def filter_for_descriptor
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
