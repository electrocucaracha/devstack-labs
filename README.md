# Devstack labs
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![GitHub Super-Linter](https://github.com/electrocucaracha/devstack-labs/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
![visitors](https://visitor-badge.glitch.me/badge?page_id=electrocucaracha.devstack-labs)

This project provisions Devstack deployments on Virtual Machines
hosted on a specific OpenStack Cluster or AWS provider. Those Devstack VMs are
reachable via jumpbox.

## OpenStack deployment

Terraform OpenStack provider requires `OS_*` environment variables to be set
before you can run the scripts. Those values depend on the OpenStack Cloud
provider.

```bash
curl -fsSL http://bit.ly/install_pkg | PKG_COMMANDS_LIST="terraform" bash
source defaults.env
terraform init
terraform apply -target module.openstack-provider -auto-approve
```

## AWS deployment

Terraform AWS provider requires access keys for CLI, those can be generated from
`My security credentials` [web console](https://console.aws.amazon.com/iam/home#/security_credentials)
and passing them to the AWS client during the configuration step.

```bash
curl -fsSL http://bit.ly/install_pkg | PKG_COMMANDS_LIST="terraform,aws" bash
aws configure
terraform init
terraform apply -target module.aws-provider -auto-approve
```
