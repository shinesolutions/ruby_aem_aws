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
require_relative 'examples/health_checker'
require_relative '../../../lib/ruby_aem_aws/component/author_publish_dispatcher'

author_publish_dispatcher = RubyAemAws::Component::AuthorPublishDispatcher.new(nil, nil)

describe author_publish_dispatcher do
  it_behaves_like 'a health_checker'
end

describe 'AuthorPublishDispatcher.healthy?' do
  module TestConstants
    INSTANCE_COMPONENT = RubyAemAws::Component::AuthorPublishDispatcher::EC2_COMPONENT
    INSTANCE_NAME = RubyAemAws::Component::AuthorPublishDispatcher::EC2_NAME
    INSTANCE_FILTER = [
      { StackPrefix: STACK_PREFIX },
      { Component: INSTANCE_COMPONENT },
      { Name: INSTANCE_NAME }
    ].freeze
    INSTANCE_1_ID = 'i-00525b1a281aee5b9'.freeze
    INSTANCE_2_ID = 'i-00525b1a281aee5b7'.freeze
    INSTANCE_3_ID = 'i-00525b1a281aee5b5'.freeze
  end

  # Intentional replication AWS instance filter logic for use by mock EC2 Resource.
  private def filter_instances(instances, filters)
    filtered = instances
    # Include only instances that match all filters.
    filters.each do |filter|
      key, value = filter.first
      filtered = filtered.select { |i|
        found_tag = i.tags.find { |t|
          t.key == key.to_s
        }
        next if found_tag.nil?
        found_tag.value == value
      }
    end
    filtered
  end

  private def add_instance(id, state, tags)
    @instances.push(mock_ec2_instance(id, state, tags))

    allow(@mock_ec2).to receive(:instances) { filter_instances(@instances, TestConstants::INSTANCE_FILTER) }
  end

  before do
    @mock_ec2 = double('mock_ec2')

    @instances = []

    @author_dispatcher = RubyAemAws::Component::AuthorPublishDispatcher.new(@mock_ec2, STACK_PREFIX)
  end

  it 'verifies EC2 running instance' do
    add_instance(TestConstants::INSTANCE_1_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: TestConstants::INSTANCE_COMPONENT,
                 Name: TestConstants::INSTANCE_NAME)

    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies EC2 not-running instance' do
    add_instance(TestConstants::INSTANCE_1_ID,
                 INSTANCE_STATE_UNHEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: TestConstants::INSTANCE_COMPONENT,
                 Name: TestConstants::INSTANCE_NAME)

    expect(@author_dispatcher.healthy?).to equal false
  end

  it 'verifies EC2 running instance (one of many)' do
    add_instance(TestConstants::INSTANCE_1_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: TestConstants::INSTANCE_COMPONENT,
                 Name: TestConstants::INSTANCE_NAME)
    add_instance(TestConstants::INSTANCE_2_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: TestConstants::INSTANCE_COMPONENT,
                 Name: 'bob')
    add_instance(TestConstants::INSTANCE_3_ID,
                 INSTANCE_STATE_UNHEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: 'bob',
                 Name: TestConstants::INSTANCE_NAME)

    expect(@author_dispatcher.healthy?).to equal true
  end

  it 'verifies EC2 non-running instance (one of many)' do
    add_instance(TestConstants::INSTANCE_1_ID,
                 INSTANCE_STATE_UNHEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: TestConstants::INSTANCE_COMPONENT,
                 Name: TestConstants::INSTANCE_NAME)
    add_instance(TestConstants::INSTANCE_2_ID,
                 Constants::INSTANCE_STATE_HEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: TestConstants::INSTANCE_COMPONENT,
                 Name: 'bob')
    add_instance(TestConstants::INSTANCE_3_ID,
                 INSTANCE_STATE_UNHEALTHY,
                 StackPrefix: STACK_PREFIX,
                 Component: 'bob',
                 Name: TestConstants::INSTANCE_NAME)

    expect(@author_dispatcher.healthy?).to equal false
  end
end
