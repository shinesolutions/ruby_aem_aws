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

require 'ruby_aem/consolidated'
require 'ruby_aem/full_set'

module RubyAemAws
  # AemAws class represents the AWS stack for AEM.
  class AemAws
    # Initialise a Ruby AEM AWS instance.
    #
    # @param _conf configuration hash of the following configuration values:
    # - foobar: desc here
    # @return new RubyAem::Aem instance
    def initialize(_conf = {})
      # TODO: replace this client with aws-sdk-client or a wrapper
      @client = nil
    end

    # Create a consolidated instance.
    #
    # @param stack_prefix desc here
    # @return new RubyAem::Consolidated instance
    def consolidated(stack_prefix)
      RubyAemAws::Consolidated.new(@client, stack_prefix)
    end

    # Create a full set instance.
    #
    # @param stack_prefix desc here
    # @return new RubyAem::FullSet instance
    def full_set(stack_prefix)
      RubyAem::FullSet.new(@client, stack_prefix)
    end
  end
end
