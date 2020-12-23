variable "ami_id" {
  description = "AMI ID for instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for instance"
  type        = string
}

variable "availability_zone" {
  description = "Subnet AZ for instance and SG"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "List of allowed CIDR blocks for SSH connections"
  type        = list(string)
}

variable "data_volume_id" {
  description = "ID of Minecraft world data volume to attach to instance"
  type        = string
}

variable "resource_tags" {
  description = "dict object of tags for resources in module"
  # type        = object
}
