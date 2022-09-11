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

require_relative 'component'

module RubyAemAws
  # Add method to scan for snapshots
  module AbstractSnapshot
    include AbstractComponent

    # @param snapshot_id Type of snapsthot to look for
    # @return Class Aws::EC2::Snapshot
    def get_snapshot_by_id(snapshot_id)
      ec2_resource.snapshot(snapshot_id).data
    end

    # @param snapshot_type Type of snapsthot to look for
    # @return EC2 Resource snapshots collection
    def get_snapshots_by_type(snapshot_type)
      ec2_resource.snapshots(filter_for_snapshot(snapshot_type))
    end
  end
end
