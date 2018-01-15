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

# Mixin for checking health of a component via ELB count.
module HealthyInstanceCountVerifier
  def healthy?
    @descriptor = get_descriptor

    asg = find_auto_scaling_group(get_asg_client)
    unless asg.nil?
      puts("ASG: #{asg.auto_scaling_group_name} (#{asg.desired_capacity})")
      asg.instances.each do |i|
        puts("   Instance #{i.instance_id}: #{i.health_status}")
      end
    end

    healthy_instance_count = 0
    elb = find_elb(get_elb_client)
    unless elb.nil?
      puts("ELB: #{elb.load_balancer_name}, #{elb.instances.length}")

      get_instances_state_from_elb(elb).each do |i|
        puts("  Instance #{i[:id]}: #{i[:state]}")
        healthy_instance_count += 1 if i[:state] == Constants::ELB_INSTANCE_STATE_HEALTHY
      end
    end

    !elb.nil? && !asg.nil? && healthy_instance_count == asg.desired_capacity
  end

  # @return ElasticLoadBalancer by StackPrefix and logical-id tags.
  private def find_elb(elb_client)
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

      return elb if elb_matches_stack_prefix && elb_matches_logical_id
    end

    nil
  end

  # @return AutoScalingGroup by StackPrefix and Component tags.
  private def find_auto_scaling_group(asg_client)
    autoscaling_groups = asg_client.describe_auto_scaling_groups
    autoscaling_groups.auto_scaling_groups.each do |autoscaling_group|
      asg_matches_stack_prefix = false
      asg_matches_component = false
      tags = autoscaling_group.tags
      tags.each do |tag|
        if tag.key == 'StackPrefix' && tag.value == @descriptor.stack_prefix
          asg_matches_stack_prefix = true
          break if asg_matches_component
          next
        end

        if tag.key == 'Component' && tag.value == @descriptor.ec2.component
          asg_matches_component = true
          break if asg_matches_stack_prefix
        end
      end

      return autoscaling_group if asg_matches_stack_prefix && asg_matches_component
    end
    nil
  end

  private def get_instances_state_from_elb(elb)
    stack_prefix_instances = []
    elb.instances.each do |i|
      instance = get_ec2_client.instance(i.instance_id)
      instance.tags.each do |tag|
        next if tag.key != 'StackPrefix'
        break if tag.value != @descriptor.stack_prefix

        stack_prefix_instances.push(id: i.instance_id, state: instance.state.name)
      end
    end
    stack_prefix_instances
  end
end
