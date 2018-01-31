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

require_relative 'abstract_component'
require_relative 'mixins/healthy_instance_state_verifier'

module RubyAemAws
  module Component
    # Interface to the AWS instance running the Orchestrator component of a full-set AEM stack.
    class Orchestrator
      include AbstractComponent
      include HealthyInstanceStateVerifier

      # @param _stack_prefix AWS tag: StackPrefix
      # @return new RubyAemAws::FullSet::Orchestrator
      def initialize(_stack_prefix) end

      def healthy?
        raise NotYetImplementedError
      end

      # def get_all_instances

      # def get_random_instance

      # def get_num_of_instances

      # def terminate_all_instances

      # def terminate_random_instance

      # def wait_until_healthy
    end
  end
end
