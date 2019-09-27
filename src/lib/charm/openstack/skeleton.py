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

import charms_openstack.charm


class SkeletonCharm(charms_openstack.charm.OpenStackCharm):
    release = 'queens'
    name = 'skeleton'
    packages = ['openntpd']
    services = ['openntpd']
    required_relations = ['certificates', 'some-ep']
    restart_map = {
        '/etc/openntpd/ntpd.conf': services,
    }
    python_version = 3
    source_config_key = 'source'

    def method(self):
        return True
