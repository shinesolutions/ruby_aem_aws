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

module RubyAemAws
  module Component
    # Interface to the AWS instance running the Author component of a full-set AEM stack.
    class Author
      include AbstractComponent

      # @param client AWS EC2 client
      # @param _stack_prefix AWS tag: StackPrefix
      # @return new RubyAemAws::FullSet::Author
      def initialize(client, _stack_prefix)
        @client = client
      end

      def healthy?
        raise NotYetImplementedError
      end

      # def get_primary_instance

      # def get_standby_instance

      # def terminate_primary_instance

      # def terminate_standby_instance

      # def wait_until_healthy
    end
  end
end
