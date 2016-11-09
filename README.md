terraform-devstack-labs
=======================

This Terraform project offers a deployment of OSIC lab enviroment, which contains devstack boxes reachable via jumpbox.

# Requirements:

* [Terraform] (https://www.terraform.io/intro/getting-started/install.html)
- Customize according to your OpenStack Provider

## General OpenStack settings

Terraform OpenStack provider needs environment variables to be set
before you can run the scripts. In general, you can simply export OS
environment variables like the following:

```
export OS_TENANT_NAME=osic-engineering
export OS_AUTH_URL=https://cloud1.osic.org:5000/v2.0
export OS_DOMAIN_NAME=Default
export OS_REGION_NAME=RegionOne
export OS_PASSWORD=secret
export OS_USERNAME=demo
```
Those values depend on the OpenStack Cloud provider.

## Steps for execution:

```
$ git clone https://github.com/electrocucaracha/terraform-devstack-labs.git
$ cd terraform-devstack-labs
$ terraform apply
```

## Destroy:

    terraform destroy
