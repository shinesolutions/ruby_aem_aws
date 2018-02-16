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
      attr_reader :author_primary, :author_standby

      ELB_ID = 'AuthorLoadBalancer'.freeze
      #ELB_NAME = 'AEM Author Load Balancer'.freeze
      ELB_NAME = 'michaelb-AuthorLo-GD3OAO968YX'.freeze

      # @param stack_prefix AWS tag: StackPrefix
      # @param ec2_resource AWS EC2 resource
      # @param elb_client AWS ELB client
      # @param cloud_watch_client AWS CloudWatch client
      # @return new RubyAemAws::FullSet::Author
      def initialize(stack_prefix, ec2_resource, elb_client, cloud_watch_client)
        @author_primary = Component::AuthorPrimary.new(stack_prefix, ec2_resource, cloud_watch_client)
        @author_standby = Component::AuthorStandby.new(stack_prefix, ec2_resource, cloud_watch_client)
        @ec2_resource = ec2_resource
        @elb_client = elb_client
      end

      def terminate_primary_instance
        instances = @ec2_resource.instances(filter_for_descriptor(@author_primary))
        instances.each do |instance|
          instance.stop(force: true)
        end
      end

      def terminate_standby_instance
        instances = @ec2_resource.instances(filter_for_descriptor(@author_standby))
        instances.each do |instance|
          puts instance.stop(force: true)
        end
      end

      # Not Working, since ELB name contains spaces atm 16/02/2018
      def describe_loadbalancer
        @elb_client.describe_load_balancers( {
                                              load_balancer_names: [
                                                ELB_NAME,
                                              ],
                                            } )
      end


      private def filter_for_descriptor(instance)
        {
          filters: [
            { name: 'tag:StackPrefix', values: [instance.descriptor.stack_prefix] },
            { name: 'tag:Component', values: [instance.descriptor.ec2.component] },
            { name: 'tag:Name', values: [instance.descriptor.ec2.name] }
          ]
        }
      end

      # def wait_until_healthy
      #   - wait until both primary and standby are healthy
      # end
    end
  end
end
