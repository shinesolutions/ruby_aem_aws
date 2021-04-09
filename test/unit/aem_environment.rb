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

module Aws
  # Stores AEM clients for convenience.
  class AemEnvironment
    attr_reader :ec2_resource, :asg_client, :elb_client, :cloud_watch_client

    def initialize(ec2_resource, asg_client, elb_client, cloud_watch_client)
      @ec2_resource = ec2_resource
      @asg_client = asg_client
      @elb_client = elb_client
      @cloud_watch_client = cloud_watch_client
    end
  end
end
