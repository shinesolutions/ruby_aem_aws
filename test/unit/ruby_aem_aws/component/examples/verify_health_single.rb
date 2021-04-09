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

shared_examples 'a health by state verifier' do
  it 'because it responds to .health_state method' do
    is_expected.to respond_to(:healthy?)
    is_expected.to respond_to(:wait_until_healthy)
  end
end

shared_examples_for 'health via single verifier' do
  before do
    @instance_1_id = 'i-00525b1a281aee5b9'.freeze
  end

  it 'should verify EC2 running instance' do
    add_instance(environment, @instance_1_id, INSTANCE_STATE_HEALTHY)

    component = create_component.call(environment)
    expect(component.healthy?).to equal true
  end

  it 'should verify no EC2 running instance' do
    component = create_component.call(environment)
    expect(component.healthy?).to equal false
  end

  it 'should discover wait_until_healthy is not yet implemented' do
    component = create_component.call(environment)
    # TODO: checked exceptions seem not to work well, so using string regex instead.
    # expect(component.wait_until_healthy).to raise_error(NotYetImplementedError)
    expect { component.wait_until_healthy }.to raise_error(/Not yet implemented/)
  end
end
