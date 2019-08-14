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

module RubyAemAws
  class InstanceState
    PENDING = 'pending'.freeze
    RUNNING = 'running'.freeze
    SHUTTING_DOWN = 'shutting_down'.freeze
    TERMINATED = 'terminated'.freeze
    STOPPING = 'stopping'.freeze
    STOPPED = 'stopped'.freeze

    ALL_ACTIVE = [PENDING, RUNNING, SHUTTING_DOWN, STOPPING, STOPPED].freeze
  end

  # API InstanceState codes https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_InstanceState.html
  class InstanceStateCode
    PENDING = 0
    RUNNING = 16
    SHUTTING_DOWN = 32
    TERMINATED = 48
    STOPPING = 64
    STOPPED = 80
  end

  class ELBInstanceState
    INSERVICE = 'InService'.freeze
    OUTOFSERVICE = 'OutOfService'.freeze

    ALL_ACTIVE = [INSERVICE, OUTOFSERVICE].freeze
  end

  class Constants
    REGION_DEFAULT = 'ap-southeast-2'.freeze
    ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'] || ENV['aws_access_key_id']
    SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'] || ENV['aws_scret_access_key']
    PROFILE = ENV['AWS_PROFILE']
    INSTANCE_STATE_HEALTHY = RubyAemAws::InstanceState::RUNNING.freeze
    INSTANCE_STATE_CODE_RUNNING = RubyAemAws::InstanceStateCode::RUNNING
    ELB_INSTANCE_INSERVICE = RubyAemAws::ELBInstanceState::INSERVICE.freeze
  end
end
