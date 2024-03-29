# Copyright 2018-2021 Shine Solutions Group
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

shared_examples 'a health by count verifier' do
  it 'because it responds to .healthy? method' do
    is_expected.to respond_to(:healthy_elb?)
    is_expected.to respond_to(:healthy_asg?)
    is_expected.to respond_to(:health_state_elb)
    is_expected.to respond_to(:health_state_asg)
    is_expected.to respond_to(:wait_until_healthy_elb)
    is_expected.to respond_to(:wait_until_healthy_asg)
  end
end

shared_examples 'health via grouped verifier' do
  before do
    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze
  end

  it 'should verify EC2 instance running in ASG' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)

    component = create_component.call(environment)
    expect(component.healthy_asg?).to equal true
  end

  it 'should verify no EC2 instances running in ASG' do
    component = create_component.call(environment)
    expect(component.healthy_asg?).to equal false
  end

  # it 'verifies ELB running instances (2) against ASG desired capacity (2)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 2 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #   add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state_elb).to equal :ready
  #   expect(component.healthy_elb?).to equal true
  # end
  #
  # it 'verifies ELB running instances (2) against ASG desired capacity (3)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 3 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #   add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to eq :recovering
  #   expect(component.healthy?).to equal false
  # end
  #
  # it 'verifies ELB running instances (1/2) against ASG desired capacity (2)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 2 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #   add_instance(environment, @instance_2_id, INSTANCE_STATE_UNHEALTHY, INSTANCE_STATE_CODE_UNHEALTHY)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to equal :recovering
  #   expect(component.healthy?).to equal false
  # end
  #
  # it 'verifies ELB running instances (2) against ASG desired capacity (1)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 1 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #   add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to equal :scaling
  #   expect(component.healthy?).to equal true
  # end
  #
  # it 'verifies ELB running instances (1/2) against ASG desired capacity (1)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 1 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #   add_instance(environment, @instance_2_id, INSTANCE_STATE_UNHEALTHY, INSTANCE_STATE_CODE_UNHEALTHY)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to equal :ready
  #   expect(component.healthy?).to equal true
  # end
  #
  # it 'verifies ELB instances (0) against ASG desired capacity (0)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 0 }
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to equal :misconfigured
  #   expect(component.healthy?).to equal false
  # end
  #
  # it 'verifies ELB running instances (1) against ASG desired capacity (0)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 0 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to equal :misconfigured
  #   expect(component.healthy?).to equal false
  # end
  #
  # it 'verifies ELB non-running instances (1) against ASG desired capacity (0)' do
  #   allow(environment.asg_client.as_group).to receive(:desired_capacity) { 0 }
  #
  #   add_instance(environment, @instance_1_id, INSTANCE_STATE_UNHEALTHY, INSTANCE_STATE_CODE_UNHEALTHY)
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state).to equal :misconfigured
  #   expect(component.healthy?).to equal false
  # end
  #
  # it 'verifies ELB does not exist' do
  #   elb_client = environment.elb_client
  #   allow(elb_client).to receive(:describe_tags) {
  #     mock_elb_describe_tags_output(mock_elb_tag_description(elb_client.load_balancer_name))
  #   }
  #
  #   component = create_component.call(environment)
  #   expect(component.health_state_elb).to equal :no_elb
  #   expect(component.healthy_elb?).to equal false
  # end

  it 'verifies ASG does not exist' do
    allow(environment.asg_client.as_group).to receive(:tags) { [] }

    component = create_component.call(environment)
    expect(component.health_state_asg).to equal :no_asg
    expect(component.healthy_asg?).to equal false
  end

  # it 'should discover wait_until_healthy is not yet implemented' do
  #   component = create_component.call(environment)
  #   # TODO: checked exceptions seem not to work well, so using string regex instead.
  #   # expect(component.wait_until_healthy).to raise_error(NotYetImplementedError)
  #   expect { component.wait_until_healthy }.to raise_error(/Not yet implemented/)
  # end
end
