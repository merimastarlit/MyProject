# Web app load balancer

resource "aws_lb" "alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
  

  enable_deletion_protection = false


  tags = local.tags
}


#LB target group
resource "aws_lb_target_group" "lb_tg" {
  name     = "lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.the_vpc.id

  health_check {
    interval = 30
    #path     "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

#ALB target group attachment

# resource "aws_lb_target_group_attachment" "lb_tg_att" {
#   target_group_arn = aws_lb_target_group.lb_tg.arn
#   target_id        = aws_instance.public_instance.id
#   port             = 80

# }

#create a listener on port 80 with forward action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn

    # redirect {
    #   port        = 443
    #   protocol    = "HTTPS"
    #   status_code = "HTTP_301"
    # }
  }
}

# Register the instances with the target group -web tier
resource "aws_autoscaling_attachment" "auto_scaling_attach" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_lb_target_group.lb_tg.arn
}


# ALB Security Group

resource "aws_security_group" "alb-sg" {
  description = "security group for ALB"
  vpc_id      = aws_vpc.the_vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "https access"
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # -1 special value indicating that all protocols are allowed.
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}