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

shared_examples 'a healthy_instance_count_verifier' do
  it 'because it responds to .healthy? method' do
    is_expected.to respond_to(:healthy?)
    is_expected.to respond_to(:health_state)
  end
end

shared_examples 'a healthy_instance_state_verifier' do
  it 'because it responds to .health_state method' do
    is_expected.to respond_to(:healthy?)
  end
end

shared_examples 'a metric_verifier' do
  it 'because it responds to .metric? method' do
    is_expected.to respond_to(:metric?)
  end
  it 'because it responds to .metric_instances method' do
    is_expected.to respond_to(:metric_instances)
  end
end
