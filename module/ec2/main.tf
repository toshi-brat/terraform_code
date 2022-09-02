data "aws_ami" "ubuntu" {
  most_recent = true
}
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.s3_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_role" "s3_role" {
  name = "S3_Full_Access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "S3_Profile" {
  name = "s3_profile"
  role = "${aws_iam_role.s3_role.name}"
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
  sudo wget https://wordpress.org/wordpress-5.1.1.tar.gz
  sudo tar -xzf wordpress-5.1.1.tar.gz
  sudo cp -r wordpress/* /var/www/html/
  sudo chown -R www-data:www-data /var/www/html/
  sudo chmod -R 755 /var/www/html/
  sudo unzip latest.zip
  sudo apt install awscli -y
  sudo aws s3 cp s3://mylab321/wp-config.php /var/www/html
  sudo aws s3 cp s3://mylab321/default /etc/nginx/sites-enabled/
  sudo systemctl restart nginx.service
  EOF
  
  security_groups = [var.sg]
    key_name = "key-pair"
    iam_instance_profile = aws_iam_instance_profile.S3_Profile.name
    
  depends_on = [aws_db_instance.database-1]
  tags = {
    Name = "web-server"
  }
}

resource "aws_db_instance" "database-1" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "db_name"
  username             = "admin"
  password             = "Password123"
  #parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  availability_zone    = var.az
  db_subnet_group_name = aws_db_subnet_group.sgn.name
  #vpc_security_group_ids = [var.sgrds]
  
  }

  resource "aws_db_subnet_group" "sgn" {
  name       = "sgn"
  subnet_ids = [var.sgn, var.sgn2]

  tags = {
    Name = "My DB subnet group"
  }
}
