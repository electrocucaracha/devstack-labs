terraform-devstack-labs
=======================

This Terraform project offers a deployment of OSIC lab enviroment, which contains devstack boxes reachable via jumpbox.

# Requirements:

* [Terraform] (https://www.terraform.io/intro/getting-started/install.html)

## Steps for execution:

```bash
$ git clone https://github.com/electrocucaracha/terraform-devstack-labs.git
$ cd  terraform-devstack-labs
$ terraform apply /
    -var 'user_name=OSIC_USERNAME' /
    -var 'password=OSIC_PASSWORD'
```

## Destroy:

    terraform destroy
