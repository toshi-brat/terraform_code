resource "aws_launch_configuration" "as_conf" {
  name_prefix     = "nginx-config"
  image_id        = var.ami
  instance_type   = var.instance-type
  security_groups = [var.sg]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "frontend-web-asg" {
  name                      = "external-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = var.pri-snet
  target_group_arns         = [var.frontend-tg-arn]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "backend-web-asg" {
  name                      = "internal-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = var.pri-snet
  target_group_arns         = [var.backend-tg-arn]
  lifecycle {
    create_before_destroy = true
  }
}

#   provisioner "file" {
#     content     = data.template_file.nginx.rendered
#     destination = "/tmp/default"

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host = self.public_ip
#       private_key = file(var.ssh_priv_key)
#     }
#   }
#   provisioner "remote-exec" {
#       inline = [
#       "sudo cp /tmp/default /etc/nginx/sites-enabled/default",
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       host = self.public_ip
#       private_key = file(var.ssh_priv_key)
#     }
#   }

# }

# data "template_file" "wpconfig" {
#   template = file("files/wp-config.php")

#   vars = {
#     #db_port = aws_db_instance.database-1.port
#     db_host = var.host
#     db_user = var.username
#     db_pass = var.password
#     db_name = var.dbname
#   }
# }
# data "template_file" "nginx" {
#   template = file("files/default")
# }

