#cloud-config

ssh_pwauth: true

users:
  - name: stack
    passwd: $6$rounds=4096$mO0VaYE2siJUuM$D.ehiPYUoLt0VvMQy8Sew66uUm9HMB6pbqeG2MF3Afib4yXPiQZ9/LXD5Ty6t9a1.IWxglOFRFFtIGy1yo9dv.
    lock_passwd: False
    sudo: ["ALL=(ALL) NOPASSWD:ALL\nDefaults:stack !requiretty"]
    shell: /bin/bash

write_files:
  - content: |
        #!/bin/sh
        DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update || sudo yum update -qy
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy git || sudo yum install -qy git
        sudo chown stack:stack /home/stack
        cd /home/stack
        git clone https://git.openstack.org/openstack-dev/devstack
        cd devstack
        echo '[[local|localrc]]' > local.conf
        echo ADMIN_PASSWORD=${password} >> local.conf
        echo DATABASE_PASSWORD=${password} >> local.conf
        echo RABBIT_PASSWORD=${password} >> local.conf
        echo SERVICE_PASSWORD=${password} >> local.conf
        echo ENABLE_DEBUG_LOG_LEVEL=False >> local.conf
        echo ENABLED_SERVICES+=,q-svc,q-agt,q-dhcp,q-l3,q-meta >> local.conf
        echo disable_service n-net >> local.conf
        ./stack.sh
    path: /home/stack/start.sh
    permissions: 0755

runcmd:
  - chage -d0 stack
  - su -l stack ./start.sh
