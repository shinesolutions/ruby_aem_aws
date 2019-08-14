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

require_relative '../constants'

module RubyAemAws
  # Mixin for checking health of a component via EC2 instance state.
  # Add this to a component to make it capable of determining its own health.
  module HealthyStateVerifier
    # @return true if there are one or more instances matching the descriptor and they are all healthy.
    def healthy?
      has_instance = false
      get_all_instances.each do |i|
        next if i.nil? || i.state.code != Constants::INSTANCE_STATE_CODE_RUNNING

        has_instance = true
        return false if i.state.name != Constants::INSTANCE_STATE_HEALTHY
      end
      has_instance
    end

    def wait_until_healthy
      instance_healthy = false
      get_all_instances.each do |i|
        next if i.nil? || i.state.code != Constants::INSTANCE_STATE_CODE_RUNNING

        i.wait_until_running
        instance_healthy = true
        return false if i.state.name != Constants::INSTANCE_STATE_HEALTHY
      end
      instance_healthy
    end
  end
end
