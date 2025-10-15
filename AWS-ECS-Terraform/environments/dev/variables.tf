variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
}

variable "container_memory" {
  description = "Container memory"
  type        = number
}

variable "service_desired_count" {
  description = "Number of tasks to run"
  type        = number
}