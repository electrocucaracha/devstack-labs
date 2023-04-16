variable "ssh_public_key_path" {
  description = "SSH public key file path"
  default     = "~/.ssh/id_rsa.pub"
  type        = string
}

variable "flavor" {
  description = "Devstack instance flavor type"
  default     = "t2.xlarge"
  type        = string
}

variable "num_devstacks" {
  description = "Number of Devstack instances to be created"
  default     = 5
  type        = number
}
