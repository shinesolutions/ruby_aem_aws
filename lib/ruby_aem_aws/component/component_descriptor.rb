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
  module Component
    ComponentDescriptor = Struct.new(:stack_prefix_in, :ec2, :elb) do
      def stack_prefix
        # Unwrap from {:stack_prefix = value} to the value if necessary.
        return stack_prefix_in[:stack_prefix] if stack_prefix_in.is_a? Hash

        stack_prefix_in
      end
    end
    EC2Descriptor = Struct.new(:component, :name)
    ELBDescriptor = Struct.new(:id, :name)
  end
end
