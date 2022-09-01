output "vpc-id" {
    value = aws_vpc.vpc.id
  }

output "pub-snet-id" {
value = aws_subnet.pub-snet
}

output "pri-snet-id" {
value = aws_subnet.pri-snet
}

# output "pub-snet-id" {
#   value = aws_subnet.pub-snet
# }



# variable "snet-id" {  
# }
