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

# require 'unit_helper'
require_relative '../spec_helper'
require_relative 'examples/health_checker'
require_relative '../../../lib/ruby_aem_aws/constants'
require_relative '../../../lib/ruby_aem_aws/component/author_dispatcher'

author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(nil, nil, nil, nil)
describe author_dispatcher do
  it_behaves_like 'a health_checker'
end

describe 'AuthorDispatcher.healthy?' do
  STACK_PREFIX = 'test-prefix'.freeze

  before do
    @mock_ec2 = double('mock_ec2')
    @mock_elb = double('mock_elb')
    @mock_as = double('mock_as')

    EC2_NAME = RubyAemAws::Component::AuthorDispatcher::EC2_NAME
    EC2_COMPONENT = RubyAemAws::Component::AuthorDispatcher::EC2_COMPONENT

    ELB_NAME = RubyAemAws::Component::AuthorDispatcher::ELB_NAME
    ELB_ID = RubyAemAws::Component::AuthorDispatcher::ELB_ID

    ASG_NAME = 'asg-test'.freeze
    INSTANCE_1_ID = 'i-00525b1a281aee5b9'.freeze
    INSTANCE_1_COMPONENT = 'instance-a'.freeze

    asg = mock_as_group(ASG_NAME,
                        1,
                        [mock_as_instance(INSTANCE_1_ID, Constants::ELB_INSTANCE_STATE_HEALTHY)],
                        mock_as_tag('StackPrefix', STACK_PREFIX),
                        mock_as_tag('Component', EC2_COMPONENT))
    allow(@mock_as).to receive(:describe_auto_scaling_groups) { mock_as_groups_type(asg) }

    instances = mock_elb_instance(INSTANCE_1_ID)
    elb_description = mock_lb_description(ELB_NAME, instances)
    elb_access_points = mock_elb_access_points(elb_description)
    allow(@mock_elb).to receive(:describe_load_balancers) { elb_access_points }

    allow(@mock_elb).to receive(:describe_tags) {
      mock_elb_describe_tags_output(
        mock_elb_tag_description(ELB_NAME,
                                 mock_elb_tag('StackPrefix', STACK_PREFIX),
                                 mock_elb_tag('aws:cloudformation:logical-id', ELB_ID)))
    }

    allow(@mock_ec2).to receive(:instance) {
      raise 'Instance not mocked'
    }
    @instances = Hash.new {}
    @instances[INSTANCE_1_ID] = mock_ec2_instance(INSTANCE_1_ID,
                                                  Constants::ELB_INSTANCE_STATE_HEALTHY,
                                                  ec2_tag(INSTANCE_1_ID, 'StackPrefix', STACK_PREFIX))
    allow(@mock_ec2).to receive(:instance).with(INSTANCE_1_ID) { @instances[INSTANCE_1_ID] }

    @author_dispatcher = RubyAemAws::Component::AuthorDispatcher.new(@mock_ec2, @mock_elb, @mock_as, STACK_PREFIX)
  end

  it 'verifies ELB running instances against ASG desired capacity' do
    expect(@author_dispatcher.healthy?).to equal true
  end
end
