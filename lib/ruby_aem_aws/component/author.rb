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

require_relative 'author_primary'
require_relative 'author_standby'

module RubyAemAws
  module Component
    # Interface to the AWS instances running the Author components of a full-set AEM stack.
    class Author
      attr_reader :instance_primary, :instance_standby

      # @param stack_prefix AWS tag: StackPrefix
      # @param ec2_resource AWS EC2 resource
      # @return new RubyAemAws::FullSet::Author
      def initialize(stack_prefix, ec2_resource, cloud_watch_client)
        @instance_primary = Component::AuthorPrimary.new(stack_prefix, ec2_resource, cloud_watch_client)
        @instance_standby = Component::AuthorStandby.new(stack_prefix, ec2_resource, cloud_watch_client)
      end

      # def get_primary_instance
      #   @instance_primary.get_instance
      # end

      # def get_standby_instance
      #   @instance_standby.get_instance
      # end

      # def terminate_primary_instance

      # def terminate_standby_instance

      # def wait_until_healthy
      #   - wait until both primary and standby are healthy
      # end
    end
  end
end
