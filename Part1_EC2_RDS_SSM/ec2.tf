#Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name= "alb-sg"
  description = "Security Group for Application Load Balancer"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port= 80
    to_port= 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# Security Group for EC2 Instances
resource "aws_security_group" "ec2_sg" {
  name = "ec2-sg"
  description = "Security Group for Web Server Instances"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

#Application Load Balancer
resource "aws_lb" "app_lb" {
  name = "app-lb"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public_subnet[*].id
  depends_on = [aws_internet_gateway.igw_vpc]
}

# Target Group for ALB
resource "aws_lb_target_group" "alb_ec2_tg" {
  name = "web-server-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "alb_ec2_tg"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_ec2_tg.arn
  }
  tags = {
    Name = "alb-listener"
  }
}

#3. Launch Template for EC2 Instances
resource "aws_launch_template" "ec2_launch_template" {
  name = "web-server-v2"

  image_id = "ami-0f340b1771dc25029"
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [aws_security_group.ec2_sg.id]
  }

  user_data = filebase64("userdata.sh")

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2-web-server"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_asg" {
  name = "web-server-asg"
  desired_capacity = 1
  min_size = 1
  max_size = 2
  target_group_arns = [aws_lb_target_group.alb_ec2_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  health_check_type = "EC2"
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}