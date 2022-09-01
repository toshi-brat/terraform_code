output "ouput-sg-id" {

    value = {for k,v in aws_security_group.vpc-sg: k => v.id}
  
}