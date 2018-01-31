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

shared_examples 'a healthy_instance_state_verifier' do
  it 'because it responds to .health_state method' do
    is_expected.to respond_to(:healthy?)
  end
end

shared_examples_for 'health via instance state' do
  it 'should verify EC2 running instance' do
    add_instance(@instance_1_id, INSTANCE_STATE_HEALTHY)

    expect(mock_author_primary.healthy?).to equal true
  end

  it 'should verify no EC2 running instance' do
    expect(mock_author_primary.healthy?).to equal false
  end
end
