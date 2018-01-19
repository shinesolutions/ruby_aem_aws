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
module RubyAemAws
  # Add this to a component to make it capable of determining its own health.
  module HealthyInstanceCountVerifier
    def healthy?
      %i[ready scaling].include? health_state
    end

    def health_state
      @descriptor = get_descriptor

      asg = find_auto_scaling_group(get_asg_client)
      return :no_asg if asg.nil?

      # Debug:
      # unless asg.nil?
      #   puts("ASG: #{asg.auto_scaling_group_name} (#{asg.desired_capacity})")
      #   asg.instances.each do |i|
      #     puts("  Instance #{i.instance_id}: #{i.health_status}")
      #   end
      # end

      elb = find_elb(get_elb_client)
      return :no_elb if elb.nil?

      elb_running_instances = 0
      # puts("ELB: #{elb.load_balancer_name} (#{elb.instances.length})")
      get_instances_state_from_elb(elb).each do |i|
        # puts("  Instance #{i[:id]}: #{i[:state]}")
        elb_running_instances += 1 if i[:state] == RubyAemAws::Constants::INSTANCE_STATE_HEALTHY
      end

      desired_capacity = asg.desired_capacity
      # puts("calc health_state: #{elb_running_instances} / #{desired_capacity}")
      return :misconfigured if desired_capacity < 1

      return :recovering if elb_running_instances < desired_capacity
      return :scaling if elb_running_instances > desired_capacity
      :ready
    end

    private

    # @return AutoScalingGroup by StackPrefix and Component tags.
    def find_auto_scaling_group(asg_client)
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

    # @return ElasticLoadBalancer by StackPrefix and logical-id tags.
    def find_elb(elb_client)
      elbs = elb_client.describe_load_balancers.load_balancer_descriptions
      elbs.each do |elb|
        elb_matches_stack_prefix = false
        elb_matches_logical_id = false
        tag_descriptions = elb_client.describe_tags(load_balancer_names: [elb.load_balancer_name]).tag_descriptions
        next if tag_descriptions.empty?

        tags = tag_descriptions[0].tags
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

    def get_instances_state_from_elb(elb)
      stack_prefix_instances = []
      elb.instances.each do |i|
        instance = get_ec2_resource.instance(i.instance_id)
        next if instance.nil?
        instance.tags.each do |tag|
          next if tag.key != 'StackPrefix'
          break if tag.value != @descriptor.stack_prefix
          stack_prefix_instances.push(id: i.instance_id, state: instance.state.name)
        end
      end
      stack_prefix_instances
    end
  end
end
