data "aws_ami" "ubuntu" {
  most_recent = true
}

 

  resource "aws_instance" "web" {
  ami           = var.ami
  subnet_id = var.pub-snet
  instance_type = "t2.micro"
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install nginx -y
  sudo apt install php-fpm php-mysql -y
  sudo apt install mysql-server -y
  systemctl start nginx.service
  systemctl start php8.1-fpm.service
  cd /var/www/html
  sudo wget https://wordpress.org/latest.zip
  sudo unzip latest.zip
  
  EOF
  
  security_groups = [var.sg]
    key_name = "key-pair"
    
  tags = {
    Name = "web-server"
  }
}

resource "aws_db_instance" "database-1" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "Password123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  availability_zone    = var.az
}
