variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Container memory"
  type        = number
  default     = 512
}

variable "service_desired_count" {
  description = "Number of tasks to run"
  type        = number
  default     = 2
}