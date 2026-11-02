provider "aws" {
  region  = var.region
  profile = var.profile
}

terraform {
  backend "s3" {
    region = var.region
  }
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = var.remote_state_key
    region = var.region
  }
}

resource "aws_ecs_cluster" "production-fargate-cluster" {
  name = var.ecs-cluster-name
}

resource "aws_alb" "ecs-cluster-alb" {
  name               = "${var.ecs-cluster-name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs-alb-security-group.id]
  subnets = [
    data.terraform_remote_state.infrastructure.outputs.public_subnet_1_id,
    data.terraform_remote_state.infrastructure.outputs.public_subnet_2_id,
    data.terraform_remote_state.infrastructure.outputs.public_subnet_3_id,
  ]

  tags = {
    Name = "${var.ecs-cluster-name}-alb"
  }
}


resource "aws_alb_listener" "ecs-cluster-alb-https-listener" {
  load_balancer_arn = aws_alb.ecs-cluster-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = "${aws_acm_certificate.ecs_domain_certificate.arn}"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-default-target-group.arn
  }

  depends_on = [aws_alb_target_group.ecs-default-target-group]
}

resource "aws_alb_target_group" "ecs-default-target-group" {
  name     = "${var.ecs-cluster-name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.infrastructure.outputs.vpc_id

  tags = {
    Name = "${var.ecs-cluster-name}-tg"
  }
}

resource "aws_route53_record" "ecs_load_balancer_record" {
  name    = "*.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain_zone.zone_id
  alias {
    name                   = aws_alb.ecs-cluster-alb.dns_name
    zone_id                = aws_alb.ecs-cluster-alb.zone_id
    evaluate_target_health = false  
  }
}


resource "aws_iam_role" "ecs_cluster_role" {
  name = "${var.ecs-cluster-name}-IAM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          "Service" = ["ecs.amazonaws.com","ec2.amazonaws.com","application-autoscaling.amazonaws.com"]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy"  "ecs_cluster_policy"{
  name = "${var.ecs-cluster-name}-IAM-Policy"
  role   = aws_iam_role.ecs_cluster_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:*",
          "ec2:*",
          "application-autoscaling:*",
          "ecr:*",
          "elasticloadbalancing:*",
          "dynamodb:*",
          "s3:*",
          "cloudwatch:*",
          "sns:*",
          "sms:*",
          "logs:*",
          "rds:*",
          "dynamodb:*",
          "kms:*",
          "ssm:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}