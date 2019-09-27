# Overview

Skeleton provides an example reactive charm

# Usage

    tox -e build
    tox -c build/builds/skeleton/tox.ini -e func-smoke

    cd build/builds/skeleton
    source .tox/func-smoke/bin/activate
    functest-configure -m MODEL_NAME -c module.path.to.configure.function
    functest-test -m MODEL_NAME -t module.path.to.test.Class

# Bugs

Please report bugs on [Launchpad](https://bugs.launchpad.net/openstack-charms/+filebug).

For general questions please refer to the OpenStack [Charm Guide](https://docs.openstack.org/charm-guide/latest/).
