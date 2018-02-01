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

describe 'Author' do
  before do
    @author = init_full_set.author
  end

  it 'Primary is healthy' do
    expect(@author.author_primary.healthy?).to eq(true)
  end

  it 'Primary has metric \'CPUUtilization\'' do
    expect(@author.author_primary.metric?(:CPUUtilization)).to eq(true)
  end

  it 'Primary does not have metric \'bob\'' do
    expect(@author.author_primary.metric?(:bob)).to eq(false)
  end

  it 'Standby is healthy' do
    expect(@author.author_standby.healthy?).to eq(true)
  end

  it 'Standby has metric \'CPUUtilization\'' do
    expect(@author.author_standby.metric?(:CPUUtilization)).to eq(true)
  end

  it 'Standby does not have metric \'bob\'' do
    expect(@author.author_standby.metric?(:bob)).to eq(false)
  end
end
