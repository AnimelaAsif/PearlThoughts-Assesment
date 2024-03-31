provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_ecs_cluster" "medusa-cluster" {
  name = "medusa-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "medusa-task" {
  family = "medusa-task"
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"

  requires_compatibilities = [
    "FARGATE"
  ]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "medusa-container"
      image     = var.docker_image_repo
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "medusa-service" {
  name            = "medusa-service"
  cluster         = aws_ecs_cluster.medusa-cluster.id
  task_definition = aws_ecs_task_definition.medusa-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [var.security_group_id]
    assign_public_ip = true
  }
}
