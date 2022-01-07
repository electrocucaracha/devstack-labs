variable "image" {
  default = "ubuntu-14.04-cloud"
}

variable "flavor" {
  default = "m2.large"
}

variable "external_gateway" {
  default = "7004a83a-13d3-4dcd-8cf5-52af1ace4cae"
}

variable "floating_pool" {
  default = "GATEWAY_NET"
}

variable "num_devstacks" {
  default = 5
}
