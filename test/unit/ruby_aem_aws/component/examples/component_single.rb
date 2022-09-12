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

# require_relative '../../../../../lib/ruby_aem_aws/error'

shared_examples_for 'a single instance accessor' do
  it 'because it responds to get_instance method' do
    is_expected.to respond_to(:get_instance)
    is_expected.to respond_to(:get_all_instances)
  end
end

shared_examples_for 'single instance accessibility' do
  before do
    @instance_1_id = 'i-00525b1a281aee5b0'.freeze
    @instance_2_id = 'i-00525b1a281aee5b1'.freeze
  end

  it 'should fail when there are multiple healthy instances' do
    # @instance_count = 2
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING, {})
    add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING, {})

    component = create_component.call(environment)
    # TODO: checked exceptions seem not to work well, so using string regex instead.
    # expect { component.get_instance }.to raise_error(ExpectedSingleInstanceError)
    expect { component.get_instance }.to raise_error(/Expected exactly one instance/)
  end

  it 'should not fail when there are multiple instances but only one healthy' do
    # @instance_count = 2
    add_instance(environment, @instance_1_id, INSTANCE_STATE_UNHEALTHY, INSTANCE_STATE_CODE_UNHEALTHY, {})
    add_instance(environment, @instance_2_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING, {})

    component = create_component.call(environment)
    expect(component.get_instance.instance_id).to eq(@instance_2_id)
  end

  it 'should get single instance' do
    # @instance_count = 1
    instance_id = @instance_1_id
    add_instance(environment, instance_id, INSTANCE_STATE_HEALTHY, INSTANCE_STATE_CODE_RUNNING, {})

    component = create_component.call(environment)
    expect(component.get_instance.instance_id).to eq(instance_id)
  end
end
