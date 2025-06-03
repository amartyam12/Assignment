#ecurity Group for RDS
resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "Allow MySQL traffic"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

#Subnet Group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "RDS Subnet Group"
  }
}

# RDS Instance
resource "aws_db_instance" "rds_instance" {
  engine                 = "mysql"
  engine_version         = "8.0.41"
  identifier             = "mydb"
  db_name                = "mydb"
  username               = "admin"
  password               = "password123"
  instance_class         = "db.t3.micro"
  storage_type           = "gp2"
  allocated_storage      = 20
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "rds-db"
  }
}
