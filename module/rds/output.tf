output "dbname" {
  value = aws_db_instance.database-1.db_name
}

output "username" {
  value = aws_db_instance.database-1.username
}
output "password" {
  value = aws_db_instance.database-1.password
}
output "host" {
  value = aws_db_instance.database-1.address
}
