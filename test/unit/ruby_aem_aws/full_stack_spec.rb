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
require_relative '../../../lib/ruby_aem_aws/consolidated_stack'

describe 'FullSetStack' do
  before do
    @full_set_stack = RubyAemAws::FullSetStack.new(TEST_STACK_PREFIX, double('mock_ec2'), double('mock_elb'), double('mock_asg'))
  end

  it 'should create author_dispatcher' do
    expect(@full_set_stack.author_dispatcher).to_not be_nil
  end

  it 'should create author' do
    expect(@full_set_stack.author).to_not be_nil
  end

  it 'should create chaos_monkey' do
    expect(@full_set_stack.chaos_monkey).to_not be_nil
  end

  it 'should create orchestrator' do
    expect(@full_set_stack.orchestrator).to_not be_nil
  end

  it 'should create publish' do
    expect(@full_set_stack.publish).to_not be_nil
  end

  it 'should create publish_dispatcher' do
    expect(@full_set_stack.publish_dispatcher).to_not be_nil
  end
end
