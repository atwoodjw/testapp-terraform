variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "name_environment" {
  type = string
}

variable "vpc_cidr" {
  description = "CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_private_subnets" {
  description = "Private Subnets"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

variable "vpc_public_subnets" {
  description = "Public Subnets"
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
}
