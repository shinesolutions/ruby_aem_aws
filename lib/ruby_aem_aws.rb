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

require 'ruby_aem_aws/consolidated_stack'
require 'ruby_aem_aws/full_set_stack'

module RubyAemAws
  # AemAws class represents the AWS stack for AEM.
  class AemAws
    # Initialise a Ruby AEM AWS instance.
    #
    # @param conf configuration hash of the following configuration values:
    # - foobar: desc here
    # @return new RubyAem::Aem instance
    def initialize(conf = {})
      @ec2Client = Aws::EC2::Client.new()
      @ec2Resource = Aws::EC2::Resource.new(region: 'ap-southeast-2')
    end

    def testConnection
      result = {}
      @ec2Client.describe_regions().regions.each do | region |
        result.push('#{region.region_name} (#{region.endpoint})')
      end
      result.size > 0
    end

    # Create a consolidated instance.
    #
    # @param stack_prefix desc here
    # @return new RubyAem::ConsolidatedStack instance
    def consolidated(stack_prefix)
      RubyAemAws::ConsolidatedStack.new(@ec2Resource, stack_prefix)
    end

    # Create a full set instance.
    #
    # @param stack_prefix desc here
    # @return new RubyAem::FullSetStack instance
    def full_set(stack_prefix)
      RubyAem::FullSetStack.new(@ec2Resource, stack_prefix)
    end

  end
end
