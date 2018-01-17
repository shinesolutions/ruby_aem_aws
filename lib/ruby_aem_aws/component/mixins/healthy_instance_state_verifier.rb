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

require_relative '../../constants'

# Mixin for checking health of a component via EC2 instance state.
module HealthyInstanceStateVerifier
  # return true if there are one or more instances matching the descriptor and they are all healthy.
  def healthy?
    @descriptor = get_descriptor

    has_instance = false
    instances = get_ec2_resource.instances(
      filters: [
        { name: 'tag:StackPrefix', values: [@descriptor.stack_prefix] },
        { name: 'tag:Component', values: [@descriptor.ec2.component] },
        { name: 'tag:Name', values: [@descriptor.ec2.name] }
      ]
    )

    instances.each do |i|
      has_instance = true
      return false if i.state.name != Constants::INSTANCE_STATE_HEALTHY
    end
    has_instance
  end
end
