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
require_relative 'mixins/instance_describer'
require_relative '../error'

module RubyAemAws
  # Add common methods to all Components.
  module AbstractComponent
    include Component
    include InstanceDescriber

    def get_all_instances
      # Overridden by subclasses, required by InstanceDescriber.
      raise NotYetImplementedError
    end

    def to_s
      "#{self.class.name.split('::').last}(#{@descriptor.stack_prefix unless @descriptor.nil?})"
    end

    private def filter_for_descriptor
      {
        filters: [
          { name: 'tag:StackPrefix', values: [@descriptor.stack_prefix] },
          { name: 'tag:Component', values: [@descriptor.ec2.component] },
          { name: 'tag:Name', values: [@descriptor.ec2.name] }
        ]
      }
    end
  end
end
