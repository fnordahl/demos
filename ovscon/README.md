Overview
========

This document contain some technical details and examples of how to use the OVN
charms as demonstrated at [OVS+OVN'19](https://ovscon.site/)
([slides](https://docs.google.com/presentation/d/18llsf8rTvcsLWfQYClEibz6r-xBu-QzEEA9vEq70M8o))


Get the code
------------

    git clone https://github.com/openstack-charmers/charm-layer-ovn.git
    git clone https://opendev.org/x/charm-ovn-central.git
    git clone https://opendev.org/x/charm-ovn-chassis.git
    git clone https://opendev.org/x/charm-ovn-dedicated-chassis.git
    git clone https://opendev.org/openstack/charm-neutron-api-plugin-ovn.git


Get development dependencies
----------------------------

    sudo apt install tox python3-all-dev


Get functional test environment dependencies
--------------------------------------------

    sudo lxd init --auto
    sudo snap install --classic juju
    juju bootstrap localhost


Get a minimal Charmed OVN environment up and running
-----------------------------------------------------

    cd charm-ovn-dedicated-chassis
    tox -e build
    sudo modprobe openvswitch
    tox -c build/builds/ovn-dedicated-chassis/tox.ini -e func-smoke


### Useful test framework commands

The commands in the previous section will automatically initialize vault for
you.  In the event you need to re-initialize you can use the following steps.

    # Initialize Vault
    cd build/builds/ovn-dedicated-chassis
    source .tox/func-smoke/bin/activate
    functest-configure -m $ZAZA_MODEL -c \
        zaza.openstack.charm_tests.vault.setup.auto_initialize_no_validation

Alternatively read the [deployment guide](https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/)
entry on [Vault](https://docs.openstack.org/project-deploy-guide/charm-deployment-guide/latest/app-vault.html)
for instructions on manual Vault initialization.


Get a full OpenStack with OVN up and running
--------------------------------------------

0. Set up MAAS with access to three physical or virtual machines
1. Get openstack-base bundle and OVN overlay

```
    wget https://github.com/openstack-charmers/openstack-bundles/blob/master/stable/openstack-base/bundle.yaml
    wget https://raw.githubusercontent.com/openstack-charmers/openstack-bundles/master/development/overlays/openstack-base-ovn.yaml
```

2. Make any necessary adjustments for your hardware
3. Deploy

```
    juju deploy ./bundle.yaml --overlay ./openstack-base-ovn.yaml
```


Useful juju commands
--------------------

    # Get list of models
    juju models
    
    # Get first model with name prefixed with zaza-
    ZAZA_MODEL=$(juju models |awk '/zaza-.*/{print$1;exit}'|tr -d "*")
    
    # Watch first model with name prefixed with zaza-
    watch -c juju status --color -m $ZAZA_MODEL --relations
    
    # SSH to unit named 'ovn-central/0' in $ZAZA_MODEL model
    juju ssh -m $ZAZA_MODEL ovn-central/0
    
    # Run action on unit named 'ovn-central/0' in named model
    juju run-action -m $ZAZA_MODEL --wait ovn-central/0 pause
    juju run-action -m $ZAZA_MODEL --wait ovn-central/0 resume
    
    # Run commands on units in application named 'ovn-central' in named model
    juju run -m $ZAZA_MODEL --application ovn-central 'hooks/update-status'
    juju run -m $ZAZA_MODEL --application ovn-central \
        'ovs-appctl -t /var/run/openvswitch/ovnnb_db.ctl \
         cluster/status OVN_Northbound'


Get in touch
------------

    #openstack-charmers @ Freenode

[Juju Discourse](https://discourse.jujucharms.com/)
