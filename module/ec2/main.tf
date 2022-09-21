# data "aws_ami" "ubuntu" {
#   most_recent = true
# }
# resource "aws_iam_role_policy" "test_policy" {
#   name = "test_policy"
#   role = "${aws_iam_role.s3_role.id}"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:*"
#       ],
#       "Effect": "Allow",
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
# resource "aws_iam_role" "s3_role" {
#   name = "S3_Full_Access"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF

#   tags = {
#       tag-key = "tag-value"
#   }
# }
# resource "aws_iam_instance_profile" "S3_Profile" {
#   name = "s3_profile"
#   role = "${aws_iam_role.s3_role.name}"
# }

# resource "aws_key_pair" "keypair" {
#   key_name   = "keypairs"
#   public_key = file(var.ssh_key)
# }
  

  resource "aws_instance" "web-server" {
  for_each = var.pub-id
  subnet_id = each.value["subnet_id"]
  ami           = var.ami
  instance_type = "t2.micro"
  security_groups = [var.sg]
  key_name = "key-pair"
  # user_data = <<-EOF
  # #!/bin/bash
  # sudo apt update -y
  # sudo apt install nginx -y
  # sudo apt install php-fpm php-mysql -y
  # sudo apt install mysql-server -y
  # systemctl start nginx.service
  # systemctl start php8.1-fpm.service
  # cd /var/www/html
  # sudo wget https://wordpress.org/latest.tar.gz
  # sudo tar -xvzf latest.tar.gz
  # sudo chown -R www-data:www-data /var/www/html/
  # sudo chmod -R 755 /var/www/html/
  # sudo systemctl restart nginx.service
  # EOF
  
  #iam_instance_profile = aws_iam_instance_profile.S3_Profile.name
  #depends_on = [aws_db_instance.database-1]
  tags = {
    Name = "web-server"
  }
 }

# resource "aws_eip" "lb" {
#   instance = aws_instance.web-server.id
#   vpc      = true
# }


resource "tls_private_key" "web-key" {
  algorithum = "RSA"
}

resource "aws_key_pair" "frontend-key" {
  key_name = "web-key"
  public_key = tls_private_key.web-key.public_key_openssh  
}
 resource "local_file" "web-key" {
  content = tls_private_key.web-key.private_key_pem
  filename = "web-key.pem"   
 }
 
resource "aws_ebs_volume" "ebs-01" {
  availability_zone = "define the AZ"
  size = "size in GB"
  tags = {
    Name = "EBS Vol"
  }
}

resource "aws_volume_attachment" "ebs-01-attach" {
  depends_on = [aws_ebs_volume.ebs-01]
  device_name = "/dev/sdh" //mount path
  volume_id = aws_ebs_volume.ebs-01.id
  instance_id = aws_instance.web-server.id //where we need to attach
  force_detach = true
  }
// to mount we need to format the ebs for which we need to ssh in ec2

resource "null_resource" "nullmount" {
depends_on =[aws_volume_attachment.ebs-01-attach]
conneconnection {
  type = "ssh"
  user= "ec2-user"//"ubuntu"
  private_key = tls_private_key.web-key.private_key_pem
  host = aws_instance.web-server.public_ip
  }
  provisioner "remote-exec" {
    inline = [ 
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/ww/html",
      "sudo  rm -rf /var/ww/html",
      //" sudo git clone or se cp to copy the code"
    ]
  
  }  
}
