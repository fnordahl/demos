#!/bin/sh

set -x

PROJECT_ID=$(openstack project list -f value -c ID \
	       --domain admin_domain)
SECGRP_ID=$(openstack security group list --project $PROJECT_ID \
    | awk '/default/{print$2}')

# Workaround for LP: #1851498
openstack security group rule delete \
    $(openstack security group rule list $SECGRP_ID| awk '/IPv./{print$2}')
openstack security group rule create --egress --protocol any \
    --ethertype IPv4 $SECGRP_ID
openstack security group rule create --egress --protocol any \
    --ethertype IPv6 $SECGRP_ID
openstack security group rule create --ingress --protocol any \
    --ethertype IPv4 $SECGRP_ID
openstack security group rule create --ingress --protocol any \
    --ethertype IPv6 $SECGRP_ID

openstack network create network
openstack subnet create --network network --subnet-range 10.42.0.0/24 subnet

openstack network create --external --provider-network-type flat \
    --provider-physical-network physnet1 ext-net
openstack subnet create --subnet-range 10.246.112.0/21 --no-dhcp \
    --gateway 10.246.112.1 --network ext-net \
    --allocation-pool start=10.246.119.33,end=10.246.119.62 ext

openstack router create router
openstack router set --external-gateway ext-net router
openstack router add subnet router subnet

openstack flavor create --ram 512 --disk 8 --vcpus 1 m1.tiny
openstack quota set --cores 200 --instances 100 --ram 51200 --ports 100 \
    $PROJECT_ID
