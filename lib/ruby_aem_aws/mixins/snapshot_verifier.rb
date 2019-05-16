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
  # Mixin for checking snapshots of a component via EC2 client
  # Add this to a component to make it capable of determining its own snapshots.
  module SnapshotVerifier
    # @param snapshot_id AWS Snapshot ID
    # @return true if snapshot exists, nil if no snapshot exists
    def snapshot?(snapshot_id)
      return true unless get_snapshot_by_id(snapshot_id).nil?
    end

    # @param snapshot_type AEM snapshot type
    # @return true if snapshots exist, false is no snapshots exist
    def snapshots?(snapshot_type)
      has_snapshot = false
      get_snapshots_by_type(snapshot_type).each do |s|
        next if s.nil?

        has_snapshot = true
      end
      has_snapshot
    end
  end
end
