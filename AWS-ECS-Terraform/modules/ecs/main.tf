data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/ecs/${var.environment}-nginx"
  retention_in_days = 30

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_task_cloudwatch_policy" {
  name = "${var.environment}-ecs-cloudwatch-policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:CreateLogGroup"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.nginx.arn}",
          "${aws_cloudwatch_log_group.nginx.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-cluster"

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.environment}-nginx"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = var.container_cpu
  memory                  = var.container_memory
  execution_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "kundansah01/nginx-ecs:1.0"
      cpu       = var.container_cpu
      memory    = var.container_memory
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NGINX_HTML",
          value = "<h1>Welcome</h1>"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.nginx.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "nginx"
          "awslogs-create-group"  = "true"
          "mode"                  = "non-blocking"
        }
      }

      mountPoints = []
      volumesFrom = []
    }
  ])
}

resource "aws_ecs_service" "nginx" {
  name            = "${var.environment}-nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }
}