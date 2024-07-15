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
