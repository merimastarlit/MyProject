# # RDS DB config
# # DB subnet
# resource "aws_db_subnet_group" "db-subnet" {
#   subnet_ids = [aws_subnet.private_subnet1db.id, aws_subnet.private_subnet2db.id]
#   name       = "db subnet"
# }
# # RDS config
# resource "aws_db_instance" "RDS" {
#   allocated_storage      = 20
#   storage_type           = "gp2"
#   engine                 = "mysql"
#   engine_version         = "8.0.35"
#   instance_class         = "db.t2.micro"
#   iops                   = "3000"
#   db_name                = "rds_db"
#   username               = var.db_username
#   password               = var.db_password
#   skip_final_snapshot    = true
#   db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
#   multi_az               = true
#   vpc_security_group_ids = [aws_security_group.database_sg.id]
# }


# # SG DB tier

# resource "aws_db_security_group" "database_sg" {
#   name = "rds_sg"

#   ingress {
#     security_groups = aws_security_group.
#   }
# }
