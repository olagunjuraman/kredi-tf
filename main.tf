provider "aws" {
  region = "us-west-2" 
}

resource "aws_internet_gateway" "kredi_igw" {
  vpc_id = aws_vpc.kredi_vpc.id
}

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

resource "aws_nat_gateway" "kredi_nat_gateway" {
  allocation_id = aws_eip.kredi_eip.id
  subnet_id     = aws_subnet.kredi_subnet1.id
}

resource "aws_eip" "kredi_eip" {
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



resource "aws_vpc" "kredi_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "kredi-vpc"
  }
}

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
    Name = "kredi-subnet2"
  }
}




resource "aws_iam_role" "kredi_eks_cluster_role" {
  name = "kredi-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kredi_eks_cluster_policy" {
  role       = aws_iam_role.kredi_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "kredi_eks_node_role" {
  name = "kredi-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kredi_eks_worker_node_policy" {
  role       = aws_iam_role.kredi_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "kredi_eks_cni_policy" {
  role       = aws_iam_role.kredi_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "kredi_eks_ec2_policy" {
  role       = aws_iam_role.kredi_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "kredi_cluster" {
  name     = "kredi-cluster"
  role_arn = aws_iam_role.kredi_eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.kredi_subnet1.id, aws_subnet.kredi_subnet2.id]
  }
}

resource "aws_eks_node_group" "kredi_node_group" {
  cluster_name    = aws_eks_cluster.kredi_cluster.name
  node_group_name = "kredi-node-group"
  node_role_arn   = aws_iam_role.kredi_eks_node_role.arn
  subnet_ids      = [aws_subnet.kredi_subnet2.id, aws_subnet.kredi_subnet3.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

   depends_on = [
    aws_iam_role_policy_attachment.kredi_eks_worker_node_policy,
    aws_iam_role_policy_attachment.kredi_eks_cni_policy,
    aws_iam_role_policy_attachment.kredi_eks_ec2_policy,
  ]
}


resource "aws_db_instance" "kredi_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version         = "16.1"
  instance_class       = "db.t3.micro"  
  identifier           = "kredidb"
  username             = var.db_username
  password             = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.kredi_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.kredi_db_sg.id]

  tags = {
    Name = "KrediDB"
  }

  depends_on = [aws_eks_cluster.kredi_cluster]
}

resource "aws_db_subnet_group" "kredi_db_subnet_group" {
  name       = "kredi-db-subnet-group"
  subnet_ids = [aws_subnet.kredi_subnet2.id, aws_subnet.kredi_subnet3.id]

  tags = {
    Name = "My DB Subnet Group"
  }
}

resource "aws_security_group" "kredi_db_sg" {
  name        = "kredi-db-sg"
  description = "Security group for PostgreSQL DB allowing specific traffic"

  vpc_id = aws_vpc.kredi_vpc.id

  # Configure the security group to allow the necessary traffic
  ingress {
    from_port   = 5432  
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "KrediDBSecurityGroup"
  }
}




