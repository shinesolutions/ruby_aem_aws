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

shared_examples_for 'a grouped instance accessor' do
  it 'because it responds to get_num_of_instances method' do
    is_expected.to respond_to(:get_num_of_instances)
  end
  it 'because it responds to get_random_instance method' do
    is_expected.to respond_to(:get_random_instance)
  end
end

shared_examples_for 'grouped instance accessibility' do
  before do
    @instance_1_id = 'i-00525b1a281aee5b0'.freeze
    @instance_1_id = 'i-00525b1a281aee5b1'.freeze
  end

  it 'should count instances' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING, {})
    add_instance(environment, @instance_2_id, INSTANCE_STATE_UNHEALTHY, INSTANCE_STATE_CODE_UNHEALTHY, {})

    component = create_component.call(environment)
    expect(component.get_num_of_instances).to eq(2)
  end

  it 'should get random instance' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING, {})

    component = create_component.call(environment)
    expect(component.get_random_instance).to eq(component.get_all_instances[0])
  end
end
