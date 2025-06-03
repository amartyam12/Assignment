#create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

#create subnet
variable "vpc_availability_zones" {
  type = list(string)
  description = "Availability Zones"
  default = ["ap-south-1a", "ap-south-1b"]
}
#Public SUbnet Details
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count = length(var.vpc_availability_zones)
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index + 1)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "Public subnet"
  }
}
#Private Subnet Details
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count = length(var.vpc_availability_zones)
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc_availability_zones, count.index)
  tags = {
    Name = "Private subnet"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw_vpc" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

#Route table for public subnet
resource "aws_route_table" "rt_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_vpc.id
  }
  tags = {
    Name = "Public subnet Route Table"
  }
}
#Public Subnet association
resource "aws_route_table_association" "public_subnet_association" {
  route_table_id = aws_route_table.rt_public_subnet.id
  count = length(var.vpc_availability_zones)
  subnet_id = element(aws_subnet.public_subnet[*].id, count.index)
}


#Elastic IP
resource "aws_eip" "eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.igw_vpc]
}


#NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id = element(aws_subnet.public_subnet[*].id, 0)
  depends_on = [aws_internet_gateway.igw_vpc]
  tags = {
    Name = "Nat Gateway"
  }
}

#Route table for Private subnet
resource "aws_route_table" "rt_private_subnet" {
  depends_on = [aws_nat_gateway.nat-gateway]
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags = {
    Name = "Private subnet Route Table"
  }
}

#Route table association for private subnet
resource "aws_route_table_association" "private_subnet_association" {
  route_table_id = aws_route_table.rt_private_subnet.id
  count = length(var.vpc_availability_zones)
  subnet_id = element(aws_subnet.private_subnet[*].id, count.index)
}
