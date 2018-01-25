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

require_relative '../spec_helper'
require_relative '../../../lib/ruby_aem_aws'

describe 'Publish' do
  before do
    @publish = init_full_set.publish
  end

  after do
  end

  # TODO: publish is part of an ASG, so should handle more than one instance with same prefix,component,name.

  it 'has metric \'CPUUtilization\'' do
    expect(@publish.metric?(:CPUUtilization)).to eq(true)
  end

  it 'does not have metric \'bob\'' do
    expect(@publish.metric?(:bob)).to eq(false)
  end

  it 'has metric \'CPUUtilization\'' do
    expect(@publish.metric?(:CPUUtilization)).to eq(true)
  end

  it 'does not have metric \'bob\'' do
    expect(@publish.metric?(:bob)).to eq(false)
  end
end
