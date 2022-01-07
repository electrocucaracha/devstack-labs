# Devstack labs
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/devstack-labs/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
![visitors](https://visitor-badge.glitch.me/badge?page_id=electrocucaracha.devstack-labs)

This project provisions Devstack deployments on Virtual Machines
hosted on a specific OpenStack Cluster. Those Devstack VMs are
reachable via jumpbox.

## General OpenStack settings

Terraform OpenStack provider requires environment variables to be set
before you can run the scripts. In general, you can simply export OS
environment variables like the following:

Those values depend on the OpenStack Cloud provider.

### Requirements

```bash
curl -fsSL http://bit.ly/install_pkg | PKG_COMMANDS_LIST="terraform" bash
terraform init
```

### OpenStack deployment

```bash
source defaults.env
terraform apply -target module.openstack-provider -auto-approve
```

### AWS deployment

```bash
terraform apply -target module.aws-provider -auto-approve
```

## Destroy

```bash
terraform destroy -auto-approve
```
