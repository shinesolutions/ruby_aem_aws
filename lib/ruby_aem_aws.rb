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

require_relative 'ruby_aem_aws/consolidated_stack'
require_relative 'ruby_aem_aws/full_set_stack'

module RubyAemAws
  # AemAws class represents the AWS stack for AEM.
  class AemAws
    # @param conf configuration hash of the following configuration values:
    # - foobar: TODO desc here
    # @return new RubyAemAws::AemAws instance
    def initialize(conf = {})
      conf[:region] ||= Constants.REGION_DEFAULT

      @ec2_client = Aws::EC2::Client.new
      @ec2_resource = Aws::EC2::Resource.new(region: conf[:region])
      @elb_client = Aws::ElasticLoadBalancing::Client.new(region: conf[:region])
      @autoscaling_client = Aws::AutoScaling::Client.new(region: conf[:region])
      # The V2 API only supports Application ELBs, and we currently use Classic.
      # @elb_client = Aws::ElasticLoadBalancingV2::Client.new(region: conf[:region])
    end

    def test_connection
      result = []
      @ec2_client.describe_regions.regions.each do | region |
        result.push("Region #{region.region_name} (#{region.endpoint})")
      end
      result.length > 0
    end

    # Create a consolidated instance.
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::ConsolidatedStack instance
    def consolidated(stack_prefix)
      RubyAemAws::ConsolidatedStack.new(@ec2_resource, stack_prefix)
    end

    # Create a full set instance.
    #
    # @param stack_prefix AWS tag: StackPrefix
    # @return new RubyAemAws::FullSetStack instance
    def full_set(stack_prefix)
      RubyAemAws::FullSetStack.new(@ec2_resource, @elb_client, @autoscaling_client, stack_prefix)
    end
  end
end
