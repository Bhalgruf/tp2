resource "aws_lb" "lb" {


  name               = "${var.lb_name}-alb-public-${var.aws_region}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.front.id]
  subnets            = module.discovery.public_subnets


  enable_deletion_protection = true

  tags = {
    Environment = "BackEnd"
  }
  }


  resource "aws_security_group" "front" {
  name        = "allow_front"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.discovery.vpc_id
 
 
  tags = {
    Name = "${var.lb_name}-alb"
    }
}


resource "aws_security_group_rule" "alb-all-vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [module.discovery.vpc_cidr]
  security_group_id = aws_security_group.front.id
}

resource "aws_security_group_rule" "HTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_dest]
  security_group_id = aws_security_group.front.id
}




resource "aws_security_group_rule" "HTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_dest]
  security_group_id = aws_security_group.front.id
}


resource "aws_lb_target_group" "tg-HTTP" {
  name     = "HTTP"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.discovery.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}

resource "aws_lb_listener" "HTTP" {
    
  load_balancer_arn = aws_lb.lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg-HTTP.arn
    type             = "forward"
  }
}