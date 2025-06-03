resource "aws_vpc" "flask_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet_flask" {
  vpc_id                  = aws_vpc.flask_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
}

resource "aws_internet_gateway" "igw_flask" {
  vpc_id = aws_vpc.flask_vpc.id
}

resource "aws_route_table" "rt_flask" {
  vpc_id = aws_vpc.flask_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_flask.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet_flask.id
  route_table_id = aws_route_table.rt_flask.id
}

resource "aws_security_group" "flask_sg" {
  name        = "flask_sg"
  description = "Allow SSH and Flask app ports"
  vpc_id      = aws_vpc.flask_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ssm_role_flask" {
  name = "ssm-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach_flask" {
  role       = aws_iam_role.ssm_role_flask.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile_flask" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role_flask.name
}

resource "aws_instance" "flask_ec2" {
  ami                         = "ami-0f340b1771dc25029" # Amazon Linux 2 AMI (use latest)
  instance_type               = "t3.nano"
  subnet_id                   = aws_subnet.public_subnet_flask.id
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile_flask.name

  user_data = <<-EOF
              #!/bin/bash

              yum install -y amazon-cloudwatch-agent

              cat <<EOT > /opt/aws/amazon-cloudwatch-agent/bin/config.json
              {
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/var/log/messages",
                          "log_group_name": "EC2-System-Logs",
                          "log_stream_name": "i-0b8398f496ca71426"
                        },
                        {
                          "file_path": "/var/log/cloud-init-output.log",
                          "log_group_name": "EC2-CloudInit-Logs",
                          "log_stream_name": "i-0b8398f496ca71426"
                        }
                      ]
                    }
                  }
                }
              }
              EOT

              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s



              sudo yum update -y
              sudo yum install -y python3 git
              pip3 install flask
              sudo git clone https://github.com/amartyam12/Assignment.git app
              cd app
              python3 main.py --host=0.0.0.0 --port=5000
              EOF

  tags = {
    Name = "FlaskAppEC2"
  }
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.flask_ec2.public_ip
}
