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

shared_examples 'a single metric_verifier' do
  it 'because it responds to .metric? method' do
    is_expected.to respond_to(:metric?)
  end
  it 'because it responds to .metric_instances method' do
    is_expected.to respond_to(:metric_instances)
  end
end

shared_examples 'metrics via single verifier' do
  before do
    @mock_ec2 = mock_ec2_resource
    @mock_cloud_watch = mock_cloud_watch

    @instance_1_id = 'i-00525b1a281aee5b9'.freeze

    @metric_1_name = 'A test metric'
    @metric_2_name = 'Unmocked'
  end

  it '.metric? verifies metric exists' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])

    expect(component.metric?(@metric_1_name)).to equal true
  end

  it '.metric? verifies metric does not exist' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)
    mock_cloud_watch_metric(@mock_cloud_watch, @metric_1_name, [@instance_1_id])

    expect(component.metric?(@metric_2_name)).to equal false
  end

  private def add_instance(id, state, tags = {})
    @instances = Hash.new {} if @instances.nil?
    @instances[id] = mock_ec2_instance(id, state, tags)
    add_ec2_instance(@mock_ec2, @instances)
  end
end
