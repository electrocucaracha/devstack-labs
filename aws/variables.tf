variable "ssh_public_key_path" {
  description = "SSH public key file path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "flavor" {
  description = "Devstack instance flavor type"
  default     = "t2.xlarge"
}

variable "num_devstacks" {
  description = "Number of Devstack instances to be created"
  default     = 5
}
