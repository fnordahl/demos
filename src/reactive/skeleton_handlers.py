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

import charms.reactive as reactive

import charms_openstack.bus
import charms_openstack.charm as charm

import charmhelpers.core as ch_core


charms_openstack.bus.discover()

# Use the charms.openstack defaults for common states and hooks
charm.use_defaults(
    'charm.installed',
    'update-status',
    'upgrade-charm',
    'certificates.available',
)


@reactive.when('config.changed', 'some-ep.available')
def config_changed():
    ch_core.hookenv.log('HELLO config_changed', level=ch_core.hookenv.INFO)
    with charm.provide_charm_instance() as charm_instance:
        charm_instance.upgrade_if_available([
            reactive.endpoint_from_flag('some-ep.available'),
        ])
        charm_instance.assess_status()
