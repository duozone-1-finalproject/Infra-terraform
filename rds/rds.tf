# --------------------------------------------------------------------------------------------------
# RDS 용 보안 그룹 (Security Group for RDS)
# --------------------------------------------------------------------------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow access to RDS from EKS"
  vpc_id      = var.vpc_id # 부모로부터 전달받은 변수 사용

  # EKS Worker Node의 보안 그룹에서 오는 3306 포트 트래픽만 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.node_sg_id] # 부모로부터 전달받은 변수 사용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# --------------------------------------------------------------------------------------------------
# RDS DB 서브넷 그룹 (DB Subnet Group)
# --------------------------------------------------------------------------------------------------
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "rds-subnet-group"
  subnet_ids = var.public_subnets # 부모로부터 전달받은 변수 사용

  tags = {
    Name = "rds-subnet-group"
  }
}

# --------------------------------------------------------------------------------------------------
# Secrets Manager에서 DB 비밀번호를 가져오는 데이터 소스
# --------------------------------------------------------------------------------------------------
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "rds/testuser"
}

# --------------------------------------------------------------------------------------------------
# MariaDB RDS 인스턴스 (MariaDB RDS Instance)
# --------------------------------------------------------------------------------------------------
resource "aws_db_instance" "mariadb" {
  identifier                 = "testuser"
  engine                     = "mariadb"
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  allocated_storage          = var.db_allocated_storage
  storage_type               = "gp3"
  username                   = var.db_username
  password                   = data.aws_secretsmanager_secret_version.db_password.secret_string
  db_name                    = var.db_name
  vpc_security_group_ids     = [aws_security_group.rds_sg.id]
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet.name
  multi_az                   = false
  publicly_accessible        = true
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true

  tags = {
    Name = "testuser"
  }
}