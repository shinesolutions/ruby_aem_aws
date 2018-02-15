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
  # Raise this when a method is not yet implemented.
  class NotYetImplementedError < StandardError
    def initialize(msg = 'Not yet implemented')
      super
    end
  end

  # Raise this when a component unexpectedly has more than one instance.
  class ExpectedSingleInstanceError < StandardError
    # def initialize(count, descriptor)
    #   message << 'Expected exactly one instance'
    #   message << " but got #{count}" unless count.nil?
    #   message << "for (#{descriptor.stack_prefix}, #{descriptor.ec2.component}, #{descriptor.ec2.name})" unless descriptor.nil?
    #   super(message)
    # end

    def initialize(msg = 'Expected exactly one instance')
      super
    end
  end

  # Raise this when credentials can't be found
  class ArgumentError < StandardError
    def initialize(msg = "No credentials found!
      Set environment variable AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY or AWS_PROFILE.
      Alternative use following syntax:
      RubyAemAws::AemAws.new(aws_access_key_id, aws_scret_access_key) or
      RubyAemAws::AemAws.new(credentials_profile_name)")
      super
    end
  end
end
