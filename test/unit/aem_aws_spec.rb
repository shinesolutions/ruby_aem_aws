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

require_relative 'spec_helper'
require_relative '../../lib/ruby_aem_aws'

describe 'AemAws' do
  before do
    @mock_ec2 = double('mock_ec2_client')
    allow(RubyAemAws::AwsCreator).to receive(:create_aws) {
      {
        Ec2Client: @mock_ec2,
        Ec2Resource: double('mock_ec2_resource'),
        ElbClient: double('mock_elb_client'),
        AutoScalingClient: double('mock_auto_scaling_client')
      }
    }

    @aem_aws = RubyAemAws::AemAws.new(region: RubyAemAws::Constants::REGION_DEFAULT)
  end

  it 'should create consolidated stack' do
    expect(@aem_aws.consolidated(TEST_STACK_PREFIX)).to_not be_nil
  end

  it 'should create full-set stack' do
    expect(@aem_aws.full_set(TEST_STACK_PREFIX)).to_not be_nil
  end

  it 'should test connection' do
    mock_region = double('mock_region')
    allow(mock_region).to receive(:region_name) { 'Test Region' }
    allow(mock_region).to receive(:endpoint) { 'Test Endpoint' }

    mock_regions = double('mock_regions')
    allow(mock_regions).to receive(:regions) { [mock_region] }

    allow(@mock_ec2).to receive(:describe_regions) { mock_regions }

    expect(@aem_aws.test_connection).to equal(true)
  end
end

describe 'AemCreator' do
  it 'should create AWS objects' do
    expect(RubyAemAws::AwsCreator.create_aws).to_not be_nil
  end
end
