#!/bin/bash

# This script lives on:
# https://github.com/fnordahl/demos/blob/ovn-snap/ovn-snap/ovn-sandbox-singlenode.sh
#
# OVN Sandbox example commands freely adapted from:
# https://github.com/ovn-org/ovn/blob/master/Documentation/tutorials/ovn-sandbox.rst
#
# OVN snap snapcraft.yaml source code available at:
# https://github.com/fnordahl/ovn/tree/snap

set -xe
# TODO: request snap aliases for these
NBCTL=ovn.nbctl
SBCTL=ovn.sbctl

# For the purpose of interactive demo flexibility install Open vSwitch on the
# host and OVN in a confined snap.  This is possible thanks to snapd interface
# work done by jamespage.
sudo apt install -y openvswitch-switch
sudo snap install --edge ovn

# Allow snap to talk to host Open vSwitch
snap connect ovn:openvswitch

# Allow host Open vSwitch and/or neighbouring Open vSwitch instances to talk
# to OVN in the strictly confined snap.
$SBCTL set-connection ptcp:6642

# Add config to the local OVSDB that the OVN local Controller looks for to talk
# to OVN
ovs-vsctl set Open_vSwitch . external-ids:ovn-encap-type=geneve
ovs-vsctl set Open_vSwitch . external-ids:ovn-encap-ip=127.0.0.1
ovs-vsctl set Open_vSwitch . external-ids:ovn-remote="tcp:127.0.0.1:6642"
snap restart ovn.controller

# Create the first logical switch with one port
$NBCTL ls-add sw0
$NBCTL lsp-add sw0 sw0-port1
$NBCTL lsp-set-addresses sw0-port1 "50:54:00:00:00:01 192.168.0.2"

# Create the second logical switch with one port
$NBCTL ls-add sw1
$NBCTL lsp-add sw1 sw1-port1
$NBCTL lsp-set-addresses sw1-port1 "50:54:00:00:00:03 11.0.0.2"

# Create a logical router and attach both logical switches
$NBCTL lr-add lr0
$NBCTL lrp-add lr0 lrp0 00:00:00:00:ff:01 192.168.0.1/24
$NBCTL lsp-add sw0 lrp0-attachment
$NBCTL lsp-set-type lrp0-attachment router
$NBCTL lsp-set-addresses lrp0-attachment 00:00:00:00:ff:01
$NBCTL lsp-set-options lrp0-attachment router-port=lrp0
$NBCTL lrp-add lr0 lrp1 00:00:00:00:ff:02 11.0.0.1/24
$NBCTL lsp-add sw1 lrp1-attachment
$NBCTL lsp-set-type lrp1-attachment router
$NBCTL lsp-set-addresses lrp1-attachment 00:00:00:00:ff:02
$NBCTL lsp-set-options lrp1-attachment router-port=lrp1

# Create host userspace interfaces so that we have something familiar to
# interact with
ip link add vrf0 type vrf table 1
ip link set vrf0 up
ovs-vsctl add-port br-int sw0p1 -- \
    set Interface sw0p1 external_ids:iface-id=sw0-port1 type=internal
ip link set sw0p1 addr 50:54:00:00:00:01 vrf vrf0 up
ip addr add 192.168.0.2/24 dev sw0p1
ip route add 11.0.0.0/24 via 192.168.0.1 vrf vrf0

ip link add vrf1 type vrf table 2
ip link set vrf1 up
ovs-vsctl add-port br-int sw1p1 -- \
    set Interface sw1p1 external_ids:iface-id=sw1-port1 type=internal
ip link set sw1p1 addr 50:54:00:00:00:03 vrf vrf1 up
ip addr add 11.0.0.2/24 dev sw1p1
ip route add 192.168.0.0/2 via 11.0.0.1 vrf vrf1

# View a summary of the configuration
printf "\n=== ovn-nbctl show ===\n\n"
$NBCTL show
printf "\n=== ovn-nbctl show with wait hv ===\n\n"
$NBCTL --wait=hv show
printf "\n=== ovn-sbctl show ===\n\n"
$SBCTL show
