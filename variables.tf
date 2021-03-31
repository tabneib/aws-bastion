variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "ami_owner" {
  type    = string
  default = "099720109477" // Canonical
}

variable "bastion_ssh_sec_group_description" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "ssh_key_file" {
  type = string
}

variable "target_security_group_id" {
  type = string
}

variable "target_ingress_port" {
  type = number
}

variable "target_protocol" {
  type = string
}
variable "target_security_rule_description" {
  type = string
}