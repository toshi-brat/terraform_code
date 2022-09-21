# output "db-dns" {
#   value = aws_db_instance.database-1.address
# }

output "ec2-id" {
    value = {for k,v in aws_instance.web-server: k=>v.id}
  
}

