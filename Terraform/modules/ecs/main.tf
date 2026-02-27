resource "aws_ecs_cluster" "this" {
  name = var.aws_ecs_cluster_name

  tags = {
    Name = var.aws_ecs_cluster_name
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.container_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.container_name}-logs"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.container_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.container_name}-task-definition"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.container_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.app_count

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [var.alb_listener_https_arn]

  lifecycle {
  ignore_changes = [
    desired_count
  ]
}

  tags = {
    Name = "${var.container_name}-service"
  }
}