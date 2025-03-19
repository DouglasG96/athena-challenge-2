resource "aws_db_instance" "rds" {
  allocated_storage = 20
  engine = "mysql"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
}

resource "aws_db_subnet_group" "main" {
  name = "rds-subnet-group"
  subnet_ids = var.private_subnets
}
