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

shared_examples 'a grouped metric_verifier' do
  it 'because it responds to .metric? method' do
    is_expected.to respond_to(:metric?)
  end
  it 'because it responds to .metric_instances method' do
    is_expected.to respond_to(:metric_instances)
  end
end

# rubocop: disable BlockLength
shared_examples 'metrics via grouped verifier' do
  before do
    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze
    @metric_1_name = 'A test metric'.freeze
    @metric_2_name = 'Unmocked'.freeze
  end

  it '.metric? verifies metric exists' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_metric(environment, @metric_1_name, [@instance_1_id])

    component = create_component.call(environment)
    expect(component.metric?(@metric_1_name)).to equal true
  end

  it '.metric? verifies metric does not exist' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_metric(environment, @metric_1_name, [@instance_1_id])

    component = create_component.call(environment)
    expect(component.metric?(@metric_2_name)).to equal false
  end

  it '.metric_instances returns all instances with metric' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY)
    add_metric(environment, @metric_1_name, [@instance_1_id, @instance_2_id])

    component = create_component.call(environment)
    metric_instances = component.metric_instances(@metric_1_name)
    expect(metric_instances.length).to eq 2
  end

  it '.metric_instances returns only instances with metric' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY)
    add_metric(environment, @metric_1_name, [@instance_1_id])
    add_metric(environment, @metric_2_name, [@instance_2_id])

    component = create_component.call(environment)
    metric_instances = component.metric_instances(@metric_1_name)
    expect(metric_instances.length).to eq 1
  end
end
# rubocop: enable BlockLength
