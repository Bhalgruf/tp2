resource "aws_security_group" "WEB-sg" {
  name        = "HTTP"
  description = "HTTP"
  vpc_id      = module.discovery.vpc_id

  tags = {
    Name = "WEB-sg"
  }
}


resource "aws_security_group_rule" "web-asg-HTTP" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_dest]
  security_group_id = aws_security_group.WEB-sg.id
}

resource "aws_security_group_rule" "web-tomateport" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = [var.cidr_dest]
  security_group_id = aws_security_group.WEB-sg.id
}



resource "aws_security_group_rule" "asg-all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [module.discovery.vpc_cidr]
  security_group_id = aws_security_group.WEB-sg.id
}

data "aws_ami" "ec2_amis" {
  most_recent      = true
  owners           = ["792805144284"]

  filter {
    name   = "name"
    values = ["resto-web-001"]
  }
}


resource "aws_launch_template" "ami" {
  name = "amiresto"
  instance_type = "t2.micro"
  image_id = data.aws_ami.ec2_amis.id
  vpc_security_group_ids = [aws_security_group.WEB-sg.id]
  key_name = "deployer-key"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "amiresto"
    }
  }

}

/*resource "aws_placement_group" "autoscaling" {
  name     = "autoscaling"
  strategy = "cluster"
}*/

resource "aws_autoscaling_group" "bar" {
  name                      = "foobar3-terraform-test"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 30
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = module.discovery.public_subnets
  
   launch_template {
    id      = aws_launch_template.ami.id
    version = "$Latest"
  }


  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }


}