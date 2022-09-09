resource "aws_db_instance" "database-1" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.dbname
  username             = var.username
  password             = var.password
  #parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  availability_zone    = var.az
  db_subnet_group_name = aws_db_subnet_group.sgn.name
  vpc_security_group_ids = [var.sgrds]
  
  }

  resource "aws_db_subnet_group" "sgn" {
  name       = "sgn"
  subnet_ids = [var.sgn, var.sgn2]

  tags = {
    Name = "My DB subnet group"
  }
}
  