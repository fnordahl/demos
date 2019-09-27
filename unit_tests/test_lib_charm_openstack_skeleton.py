# Copyright 2019 Canonical Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import charms_openstack.test_utils as test_utils

import charm.openstack.skeleton as skeleton


class Helper(test_utils.PatchHelper):

    def setUp(self):
        super().setUp()
        self.patch_release(skeleton.SkeletonCharm.release)


class TestSkeletonCharm(Helper):

    def test_method(self):
        c = skeleton.SkeletonCharm()
        self.assertTrue(c.method())
