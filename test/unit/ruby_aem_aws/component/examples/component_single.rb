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

# require_relative '../../../../../lib/ruby_aem_aws/error'

shared_examples_for 'a single instance accessor' do
  it 'because it responds to get_instance method' do
    is_expected.to respond_to(:get_instance)
    is_expected.to respond_to(:get_all_instances)
  end
end

shared_examples_for 'single instance accessibility' do
  before do
    @mock_ec2 = mock_ec2_resource

    @metric_1_id = 'i-00525b1a281aee5b0'
    @metric_2_id = 'i-00525b1a281aee5b1'
  end

  it 'should fail when multiple instances' do
    # @instance_count = 2
    add_instance(@metric_1_id, INSTANCE_STATE_HEALTHY, {})
    add_instance(@metric_2_id, INSTANCE_STATE_UNHEALTHY, {})

    # expect { component.get_instance }.to raise_error(ExpectedSingleInstanceError)
    expect { component.get_instance }.to raise_error(/Expected exactly one instance/)
  end

  it 'should get single instance' do
    # @instance_count = 1
    instance_id = @metric_1_id
    add_instance(instance_id, INSTANCE_STATE_HEALTHY, {})

    expect(component.get_instance.instance_id).to eq(instance_id)
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances)
  end
end
