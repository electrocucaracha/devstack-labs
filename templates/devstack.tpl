#cloud-config

ssh_pwauth: true

users:
  - name: stack
    # the password is "stack"
    passwd: $6$rounds=4096$M.LjnloESs3IjeJ$HF2bmqXhDsO8MT7EFfRcrNaTF081kNbRxcScbBuQ3eQ8mEQUdny.17ZDb/KU3106dZ5U1iPcEVUb5yVDViyBY/
    lock_passwd: False
    sudo: ["ALL=(ALL) NOPASSWD:ALL\nDefaults:stack !requiretty"]
    shell: /bin/bash

write_files:
  - content: |
        #!/bin/sh
        DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update || sudo yum update -qy
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy git || sudo yum install -qy git
        DEBIAN_FRONTEND=noninteractive sudo apt-get remove -qqy python3-cryptography || :
        export SETUPTOOLS_USE_DISTUTILS=1
        sudo chown stack:stack /home/stack
        cd /home/stack
        git clone https://git.openstack.org/openstack-dev/devstack
        cd devstack
        echo '[[local|localrc]]' > local.conf
        echo HOST_IP=$(ip route get 8.8.8.8 | grep "^8." | awk '{ print $7 }') >> local.conf
        echo ADMIN_PASSWORD=${password} >> local.conf
        echo DATABASE_PASSWORD=${password} >> local.conf
        echo RABBIT_PASSWORD=${password} >> local.conf
        echo SERVICE_PASSWORD=${password} >> local.conf
        echo ENABLE_DEBUG_LOG_LEVEL=False >> local.conf
        echo ENABLED_SERVICES+=,neutron-svc,neutron-dhcp,neutron-meta >> local.conf
        echo ENABLED_SERVICES+=,s-proxy,s-object,s-container,s-account  >> local.conf
        echo SWIFT_HASH=swift >> local.conf
        echo disable_service n-net >> local.conf
        ./stack.sh
    path: /home/stack/start.sh
    permissions: 0755

runcmd:
  - echo stack | su -l -c "./start.sh" stack
  - chage -d0 stack
