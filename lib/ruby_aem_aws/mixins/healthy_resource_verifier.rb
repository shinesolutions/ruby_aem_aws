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
  # Mixin for checking health of a component via ELB 'healthy' count vs ASG desired_capacity.
  # Add this to a component to make it capable of determining its own health.
  module HealthyResourceVerifier
    # Aggregate health_states considered healthy.
    # @return health_state_elb is ready or scaling.
    def healthy_elb?
      %i[ready scaling].include? health_state_elb
    end

    # Aggregate health_states considered healthy.
    # @return health_state_asg is ready or scaling.
    def healthy_asg?
      %i[ready scaling].include? health_state_asg
    end

    # Provides detail of the state of the instances comprising the component.
    # @return one of:
    # - no_asg: AutoScalingGroup could not be located (by StackPrefix and Component tags).
    # - no_elb: ElasticLoadBalancer could not be located (by StackPrefix and aws:cloudformation:logical-id tags).
    # - misconfigured: AutoScalingGroup.desired_capacity is less than 1.
    # - recovering: ELB running instance count is less than AutoScalingGroup.desired_capacity.
    # - scaling: ELB running instance count is more than AutoScalingGroup.desired_capacity.
    # - ready: ELB running instance count is equal to AutoScalingGroup.desired_capacity.
    def health_state_elb
      asg = find_auto_scaling_group(asg_client)
      return :no_asg if asg.nil?

      # Debug:
      # unless asg.nil?
      #   puts("ASG: #{asg} #{asg.auto_scaling_group_name} (#{asg.desired_capacity})")
      #   asg.instances.each do |i|
      #     puts("  Instance #{i.instance_id}: #{i.health_status}")
      #   end
      # end

      elb = find_elb(elb_client)
      return :no_elb if elb.nil?

      elb_instance_state = get_instances_elb_state(elb_client, elb)
      return :no_elb_targets if elb_instance_state.nil?

      elb_running_instances = 0
      elb_instance_state.each do |i|
        elb_running_instances += 1 if i.target_health.state == RubyAemAws::Constants::ELB_INSTANCE_INSERVICE
      end

      desired_capacity = asg.desired_capacity
      return :misconfigured if desired_capacity < 1
      return :recovering if elb_running_instances < desired_capacity
      return :scaling if elb_running_instances > desired_capacity

      :ready
    end

    # Provides detail of the state of the instances comprising the component.
    # @return one of:
    # - no_asg: AutoScalingGroup could not be located (by StackPrefix and Component tags).
    # - misconfigured: AutoScalingGroup.desired_capacity is less than 1.
    # - recovering: ELB running instance count is less than AutoScalingGroup.desired_capacity.
    # - scaling: ELB running instance count is more than AutoScalingGroup.desired_capacity.
    # - ready: ELB running instance count is equal to AutoScalingGroup.desired_capacity.
    def health_state_asg
      asg = find_auto_scaling_group(asg_client)
      return :no_asg if asg.nil?

      # Debug:
      # unless asg.nil?
      #   puts("ASG: #{asg} #{asg.auto_scaling_group_name} (#{asg.desired_capacity})")
      #   asg.instances.each do |i|
      #     puts("  Instance #{i.instance_id}: #{i.health_status}")
      #   end
      # end
      instances_inservice = 0
      desired_capacity = asg.desired_capacity

      get_all_instances.each do |i|
        next if i.nil? || i.state.code != Constants::INSTANCE_STATE_CODE_RUNNING
        return false if i.state.name != Constants::INSTANCE_STATE_HEALTHY

        instances_inservice += 1
      end

      return :misconfigured if desired_capacity < 1
      return :recovering if instances_inservice < desired_capacity
      return :scaling if instances_inservice > desired_capacity

      :ready
    end

    # @return true, if all instances within the ELB are inService
    def wait_until_healthy_elb
      raise ELBMisconfiguration if health_state_elb.eql?(:misconfigured)

      sleep 60 while health_state_elb.eql?(:recovering) || health_state_elb.eql?(:scaling)
      return true if health_state_elb.eql?(:ready)
    end

    def wait_until_healthy_asg
      raise ASGMisconfiguration if health_state_asg.eql?(:misconfigured)

      sleep 60 while health_state_asg.eql?(:recovering) || health_state_asg.eql?(:scaling)
      return true if health_state_asg.eql?(:ready)
    end

    private

    # @return AutoScalingGroup by StackPrefix and Component tags.
    def find_auto_scaling_group(asg_client)
      autoscaling_groups = asg_client.describe_auto_scaling_groups(max_records: 50)
      find_auto_scaling_group = find_auto_scaling_group_name(autoscaling_groups)

      return find_auto_scaling_group unless find_auto_scaling_group.nil?

      until autoscaling_groups.next_token.nil?
        autoscaling_groups = asg_client.describe_auto_scaling_groups(max_records: 50, next_token: autoscaling_groups.next_token)
        find_auto_scaling_group = find_auto_scaling_group_name(autoscaling_groups)
        return find_auto_scaling_group unless find_auto_scaling_group.nil?
      end
      return nil if find_auto_scaling_group.nil?
    end

    def find_auto_scaling_group_name(autoscaling_groups)
      autoscaling_groups.auto_scaling_groups.each do |autoscaling_group|
        asg_matches_stack_prefix = false
        asg_matches_component = false
        tags = autoscaling_group.tags
        tags.each do |tag|
          if tag.key == 'StackPrefix' && tag.value == descriptor.stack_prefix
            asg_matches_stack_prefix = true
            break if asg_matches_component

            next
          end
          if tag.key == 'Component' && tag.value == descriptor.ec2.component
            asg_matches_component = true
            break if asg_matches_stack_prefix
          end
        end
        return autoscaling_group if asg_matches_stack_prefix && asg_matches_component
      end
      nil
    end

    # @return ElasticLoadBalancer Arn.
    def find_elb(elb_client)
      elbs = elb_client.describe_load_balancers(page_size: 50)
      elb_arn = find_elb_arn(elbs.load_balancers)

      return elb_arn unless elb_arn.nil?

      until elbs.last_page?
        elbs = elb_client.describe_load_balancers(page_size: 50, marker: elbs.next_marker)
        elb_arn = find_elb_arn(elbs.load_balancers)
        return elb_arn unless elb_arn.nil?
      end
      nil
    end

    # @return ElasticLoadBalancer Arn by StackPrefix tag & ELB name.
    def find_elb_arn(elbs)
      elbs.each do |elb|
        elb_matches_stack_prefix = false
        elb_matches_name = false
        begin
          tag_descriptions = elb_client.describe_tags(resource_arns: [elb.load_balancer_arn]).tag_descriptions
        rescue Aws::ElasticLoadBalancingV2::Errors::LoadBalancerNotFound
          next
        end

        next if tag_descriptions.empty?

        tags = tag_descriptions[0].tags
        tags.each do |tag|
          elb_matches_stack_prefix = true if tag.key == 'StackPrefix' && tag.value == descriptor.stack_prefix
          elb_matches_name = true if tag.key == 'Name' && tag.value == descriptor.elb.name

          return elb.load_balancer_arn if elb_matches_stack_prefix && elb_matches_name

          next
        end
      end
      nil
    end

    def get_instances_elb_state(elb_client, elb_arn)
      described_target_groups = elb_client.describe_target_groups(load_balancer_arn: elb_arn)

      return nil if described_target_groups.target_groups.empty?

      target_group = described_target_groups.target_groups[0]
      target_group_arn = target_group.target_group_arn

      described_target_health = elb_client.describe_target_health(target_group_arn: target_group_arn)

      return nil if described_target_health.target_health_descriptions.empty?

      described_target_health.target_health_descriptions
    end
  end
end
