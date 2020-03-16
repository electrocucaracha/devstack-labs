Devstack labs
=============

This project provisions Devstack deployments on Virtual Machines
hosted on a specific OpenStack Cluster. Those Devstack VMs are
reachable via jumpbox.

## General OpenStack settings

Terraform OpenStack provider requires environment variables to be set
before you can run the scripts. In general, you can simply export OS
environment variables like the following:

```bash
OS_REGION_NAME=RegionOne
OS_AUTH_PLUGIN=password
OS_USER_DOMAIN_NAME=Default
OS_PROJECT_NAME=admin
OS_IDENTITY_API_VERSION=3
OS_PASSWORD=l0BbfUo2Ht7VRBffY6SHqSYNnSGo6bQw8RjlDfRW
OS_AUTH_URL=http://192.168.121.59:35357/v3
OS_USERNAME=admin
OS_TENANT_NAME=admin
OS_ENDPOINT_TYPE=internalURL
OS_INTERFACE=internal
OS_PROJECT_DOMAIN_NAME=Default
```

Those values depend on the OpenStack Cloud provider.

## Steps for execution:

```bash
curl -fsSL http://bit.ly/install_pkg | PKG="terraform git" bash
git clone https://github.com/electrocucaracha/devstack-labs.git
cd devstack-labs
terraform init
terraform apply
```

## Destroy:

    terraform destroy
