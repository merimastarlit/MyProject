# RDS DB config
# DB subnet
resource "aws_db_subnet_group" "db-subnet" {
  subnet_ids = [aws_subnet.private_subnet1db, aws_subnet.private_subnet2db]
  name       = "db subnet"
}
# RDS config
resource "aws_db_instance" "RDS" {
  allocated_storage      = 100
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.m5.large"
  iops                   = "3000"
  db_name                = "rds_db"
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}


# SG DB tier
resource "aws_security_group" "database_sg" {
  description = "Database security group"
  vpc_id      = aws_vpc.the_vpc.id

  ingress {
    description     = "MYSQL access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${aws_security_group.web-sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 special value indicating that all protocols are allowed.
    cidr_blocks = ["0.0.0.0/0"]
  }
}