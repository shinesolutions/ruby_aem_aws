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

shared_examples 'a grouped instance describer' do
  it 'because it responds to describe_instances method' do
    is_expected.to respond_to(:describe_instances)
  end
end

shared_examples 'grouped instance description' do
  before do
    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
    @instance_2_id = 'i-00525b1a281aee5b7'.freeze
    @instance_3_id = 'i-00525b1a281aee5b5'.freeze
  end

  it 'describe_instances for single healthy instance' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)

    component = create_component.call(environment)
    description = component.describe_instances.split(', ')

    expect(description[0]).to include(@instance_1_id)
    expect(description[0]).to include(INSTANCE_STATE_HEALTHY)
  end

  it 'describe_instances for multiple instances with different states' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)
    add_instance(environment, @instance_2_id, INSTANCE_STATE_UNHEALTHY)
    add_instance(environment, @instance_3_id, INSTANCE_STATE_HEALTHY)

    component = create_component.call(environment)
    description = component.describe_instances.split(', ')

    expect(description[0]).to include(@instance_1_id)
    expect(description[0]).to include(INSTANCE_STATE_HEALTHY)

    expect(description[1]).to include(@instance_2_id)
    expect(description[1]).to include(INSTANCE_STATE_UNHEALTHY)

    expect(description[2]).to include(@instance_3_id)
    expect(description[2]).to include(INSTANCE_STATE_HEALTHY)
  end
end
