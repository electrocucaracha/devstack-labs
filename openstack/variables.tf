variable "image" {
  description = "Jumpbox and Devstack OS image"
  default     = "ubuntu-14.04-cloud"
  type        = string
}

variable "flavor" {
  description = "Devstack instance flavor type"
  default     = "m2.large"
  type        = string
}

variable "external_gateway" {
  description = "Gateway ID for connecting to external network"
  default     = "7004a83a-13d3-4dcd-8cf5-52af1ace4cae"
  type        = string
}

variable "floating_pool" {
  description = "Name of the pool for floating IP addresses"
  default     = "GATEWAY_NET"
  type        = string
}

variable "num_devstacks" {
  description = "Number of Devstack instances to be created"
  default     = 5
  type        = number
}
