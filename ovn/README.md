Deploy
======

The bundle deployed with overlay will consume 3 physical machines.

    juju deploy ./bundle.yaml --overlay ./openstack-base-ovn.yaml

Charm configuration
===================

Configure bridge mapping for individual network interfaces so that two out of
three physical machines get a direct external connection.

You can find the MAC address for the physical interface to use for external
networking by searching for the interface name in the 'Machine output (YAML)`
log in MAAS.

    - lshw:logicalname:
      enp3s0f0
    - lshw:version:
      01
    - lshw:serial:
      a0:36:9f:dd:31:bc

    juju config ovn-chassis interface-bridge-mappings='a0:36:9f:dd:31:bc:br-provider 01:02:03:04:05:06:br-provider'

OpenStack post deployment configuration
=======================================

Before proceeding you must do the following:

- `vault` must be initialized.

- Remember to restart services on nova-cloud-controller and nova-compute due
  to LP: #1826382

- You must retrieve the CA certificate and load `openrc`

```
    juju run-action --wait vault/0 get-root-ca  # cut'n'paste ca to ~/ca
    export OS_CACERT=$HOME/ca
    export OS_AUTH_PROTOCOL=https
    source src/openstack-charmers/openstack-charm-testing/rcs/openrc
```

There is a `script.sh` in the current directory that takes care of creating the
necessary internal and external networks and adds a 'm1.tiny' flavor.

After running that you would need to create yourself a keypair and add a ubuntu
cloud image.

Spin up a number of instances that will guarantee you to have instances on all
of the hypervisors.

    openstack server create --flavor m1.tiny --image ubuntu --key-name mykey \
        --network network --min 15 --max 15 u

Create a few floating IPs and assign to a couple of servers, do choose one that
is on one of the hypervisors that do not have external connectivity directly
attached.

Confirm connectivity.

Demo
====

Talking points
--------------

- Charm work has been carefully laid out to be consumable by other teams and
  projects.

- OVN uses TLS/PKI for authentication and authorization

  - Charm requires certificates relation (Vault)

  - RBAC enabled on the Southbound database by default. This makes it harder to
    leverage database access to attack the network in the event of a hypervisor
    getting compromised.

- One of many differences and advantages ML2+OVN give over ML2+OVS+DVR is
  support for not having external connectivety directly attached to all
  hypervisors.

- This plays nicely with Layer3-only datacenter fabrics (as exemplified in
  RFC 7938). You can configure your deployment to offload North/South
  traffic from chassis that are actually in the vincinity of border gateways
  instead of requiring a globally shared Layer2 or manual tunnel configuration
  on ToR switches.

- East/West traffic is distributed by deafult and North/South traffic is
  highly available by default (using BFD for liveness detection), as long as
  you configure two or more chassis with bridge mappings.

- Everything is programmed into Open vSwitch through OpenFlow rules,
  including IPv6 RA/ND, ARP resolution, Layer3 routing, Layer3 NAT, ACLs,
  DHCPv4/DHCPv6, internal DNS resolution.  This in turn gives a uniform way
  of programming supported NICs with the prospect of hardware-offload of
  everything.

- For OpenSatck, upstream Neutron moving towards bringing `networking-ovn` as
  the [preferred in-tree driver](https://review.opendev.org/#/c/658414/)

Things to show
--------------

You can view the resulting OVN logical configuration by connecting to the
cluster leader of the respective DBs

    juju run --application ovn-central \
        'ovs-appctl -t /var/run/openvswitch/ovnnb_db.ctl \
         cluster/status OVN_Northbound'
    juju run --application ovn-central \
        'ovs-appctl -t /var/run/openvswitch/ovnsb_db.ctl \
         cluster/status OVN_Southbound'
    juju run --unit ovn-central/N 'sudo ovn-nbctl show'
    juju run --unit ovn-central/N 'sudo ovn-sbctl show'
    juju run --unit ovn-central/N 'sudo ovn-sbctl lflow-list'

Show how a instance hanging off a hypervisor without direct external
connectivity magically gets to the internet regardless!

Show BFD status on hypervisor?

Advanced: Kill the active gateway chassis by stopping openvswitch-switch and
ovn-host and show that connectivity remains

Optionally show a [ovn-trace](https://pastebin.ubuntu.com/p/RwcdNqwbpz/) and/or
dump some flow tables etc?

    ovs-vsctl show
    ovs-ofctl dump-flows br-int
