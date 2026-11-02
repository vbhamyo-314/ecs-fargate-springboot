resource "aws_security_group" "ecs-alb-security-group" {
  name        = "${var.ecs-cluster-name}-alb-sg"
  description = "Security group for ALB to allow traffic for ECS cluster"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = [var.internet_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet_cidr_block]
  }
}

