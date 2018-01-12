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

# Mixin for checking health of a component via ELB count.
module HealthCheckELB
  def healthy?
    @descriptor = get_descriptor

    elb_client = get_elb_client
    ec2_client = get_ec2_client

    has_elb = false
    elbs = elb_client.describe_load_balancers.load_balancer_descriptions
    elbs.each do |elb|
      elb_matches_stack_prefix = false
      elb_matches_logical_id = false
      tags = elb_client.describe_tags(load_balancer_names: [elb.load_balancer_name]).tag_descriptions[0].tags
      tags.each do |tag|
        if tag.key == 'StackPrefix' && tag.value == @descriptor.stack_prefix
          elb_matches_stack_prefix = true
          break if elb_matches_logical_id
          next
        end

        if tag.key == 'aws:cloudformation:logical-id' && tag.value == @descriptor.elb.id
          elb_matches_logical_id = true
          break if elb_matches_stack_prefix
        end
      end

      next unless elb_matches_stack_prefix && elb_matches_logical_id

      puts("Name: #{elb.load_balancer_name}, #{elb.instances.length}")

      stack_prefix_instances = []
      elb.instances.each do |i|
        instance = ec2_client.instance(i.instance_id)
        instance.tags.each do |tag|
          next if tag.key != 'StackPrefix'
          break if tag.value != @descriptor.stack_prefix

          stack_prefix_instances.push(i)
        end
      end

      stack_prefix_instances.each do |i|
        puts("  Instance: #{i.instance_id}")
        # TODO: client.describe_instance_health == InService
        # TODO: compare to AutoScaling::AutoScalingGroup::desired_capacity
      end

      has_elb = true
    end

    has_elb
  end
end