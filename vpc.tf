
# VPC
resource "aws_vpc" "kredi_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "kredi-vpc"
  }
}

# Subnets
resource "aws_subnet" "kredi_subnet1" {
  vpc_id            = aws_vpc.kredi_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "kredi-subnet1"
  }
}

resource "aws_subnet" "kredi_subnet2" {
  vpc_id            = aws_vpc.kredi_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "kredi-subnet2"
  }
}

resource "aws_subnet" "kredi_subnet3" {
  vpc_id            = aws_vpc.kredi_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  tags = {
    Name = "kredi-subnet3"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "kredi_igw" {
  vpc_id = aws_vpc.kredi_vpc.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "kredi_eip" {

}

# NAT Gateway
resource "aws_nat_gateway" "kredi_nat_gateway" {
  allocation_id = aws_eip.kredi_eip.id
  subnet_id     = aws_subnet.kredi_subnet1.id
}

# Route Tables and Associations
resource "aws_route_table" "kredi_public_rt" {
  vpc_id = aws_vpc.kredi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kredi_igw.id
  }
}

resource "aws_route_table_association" "kredi_subnet1_association" {
  subnet_id      = aws_subnet.kredi_subnet1.id
  route_table_id = aws_route_table.kredi_public_rt.id
}

resource "aws_route_table" "kredi_private_rt" {
  vpc_id = aws_vpc.kredi_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.kredi_nat_gateway.id
  }
}

resource "aws_route_table_association" "kredi_subnet2_association" {
  subnet_id      = aws_subnet.kredi_subnet2.id
  route_table_id = aws_route_table.kredi_private_rt.id
}

resource "aws_route_table_association" "kredi_subnet3_association" {
  subnet_id      = aws_subnet.kredi_subnet3.id
  route_table_id = aws_route_table.kredi_private_rt.id
}

