# output "vpc-id" {
#     value = aws_vpc.vpc.id
#   }

# output "pub-snet-id" {
# value = aws_subnet.pub-snet.*.id
# }

# output "pri-snet-id" {
# value = aws_subnet.pri-snet.*.id  
# }

output "pub-snet-id" {
  value = {for k, v in aws_subnet.pub-snet : k => v.id}
}

