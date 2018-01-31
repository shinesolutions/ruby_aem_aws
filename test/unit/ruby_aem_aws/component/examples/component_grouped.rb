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
    @mock_ec2 = mock_ec2_resource
  end

  it 'should count instances' do
    @instance_count = 2
    add_instance('i-00525b1a281aee5b0', INSTANCE_STATE_HEALTHY, {})
    add_instance('i-00525b1a281aee5b1', INSTANCE_STATE_UNHEALTHY, {})

    expect(component.get_num_of_instances).to eq(@instance_count)
  end

  it 'should get random instance' do
    @instance_count = 1
    add_instance('i-00525b1a281aee5b0', INSTANCE_STATE_HEALTHY, {})

    expect(component.get_random_instance).to eq(component.get_all_instances[0])
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances)
  end
end
