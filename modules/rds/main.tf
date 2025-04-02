resource "aws_rds_cluster" "aurora_mysql" {
  cluster_identifier      = "${var.project_name}-aurora-mysql-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.6" # Update to latest version
  database_name           = "${var.project_name}db"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 7 # Days (recommended minimum)
  preferred_backup_window = "02:00-03:00" # During low traffic
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true # For dev/test environments
  deletion_protection     = true # Prevent accidental deletion
  storage_encrypted       = true # Always encrypt at rest
  apply_immediately       = false # Apply during maintenance window

  lifecycle {
    prevent_destroy = true # Extra protection against deletion
  }
}

resource "aws_rds_cluster_instance" "aurora_mysql_instances" {
  count              = var.cluster_instances
  identifier         = "${var.project_name}-aurora-mysql-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_mysql.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora_mysql.engine
  engine_version     = aws_rds_cluster.aurora_mysql.engine_version
  auto_minor_version_upgrade  = false # More control over updates
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnets
  description = "Private subnets for Aurora MySQL cluster"

  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}


data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com/" # A service that returns your public IP
}

locals {
  my_ip = "${chomp(data.http.my_public_ip.response_body)}/32"
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for Aurora MySQL cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL access from ECS security group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id] # Only allow ECS to connect
  }


  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [local.my_ip] # Allow MYSQL only from your current IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# Enhanced monitoring role (optional but recommended)
resource "aws_iam_role" "rds_monitoring_role" {
  name = "${var.project_name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}/rds/credentials"
  description = "Database credentials for ${var.project_name} Aurora MySQL"

  recovery_window_in_days = 0 # Set to 0 for immediate deletion (use 7-30 in production)

  tags = {
    Name = "${var.project_name}-db-credentials"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    DB_USER = var.db_username
    DB_PASSWORD = var.db_password
    DB_ENGINE   =  aws_rds_cluster.aurora_mysql.engine
    DB_HOST     = aws_rds_cluster.aurora_mysql.endpoint
    DB_PORT     = aws_rds_cluster.aurora_mysql.port
    DB_NAME   = aws_rds_cluster.aurora_mysql.database_name
  })
}