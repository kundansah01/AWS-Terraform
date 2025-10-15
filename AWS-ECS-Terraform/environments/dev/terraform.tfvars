environment = "dev"
aws_region  = "us-east-1"
vpc_cidr    = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
container_cpu = 256
container_memory = 512
service_desired_count = 2