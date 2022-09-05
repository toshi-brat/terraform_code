provider "aws" {
  region = "ap-south-1"
}
data "aws_availability_zones" "available" {
  state = "available"
}
module "network" {
  source   = "./module/network"
  cidr     = "10.0.0.0/20"
  app_name = "web"

  pub-snet-details = {
    s1 = {
      cidr_block        = "10.0.0.0/22"
      availability_zone = "ap-south-1a"
    },
    s2 = {
      cidr_block        = "10.0.4.0/22"
      availability_zone = "ap-south-1b"
    }
  }


  pri-snet-details = {
    ps1 = {
      cidr_block        = "10.0.8.0/22"
      availability_zone = "ap-south-1a"
    },
    ps2 = {
      cidr_block        = "10.0.12.0/22"
      availability_zone = "ap-south-1b"
    }
  }
  is_nat_required = false
  nat-pub-id = "s1"
  
}

module "sg" {
  source   = "./module/sg"
  sg_details = {
    "web-server" = {
      description = "httpd inbound"
      name = "web-server"
      vpc_id = module.network.vpc-id
      ingress_rules = [ 
        {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 80
        protocol = "tcp"
        self = null
        to_port = 80
        security_groups = null
         },
        {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        protocol = "tcp"
        self = null
        to_port = 22
        security_groups = null
         }
         
       ]      
    }
  }
}

  module "sg2" {
  source   = "./module/sg"
  sg_details = {
    "rds-db" = {
      description = "rsd inbound"
      name = "rds-db"
      vpc_id = module.network.vpc-id
      ingress_rules = [ 
        {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 3306
        protocol = "tcp"
        self = null
        to_port = 3306
        security_groups = [lookup(module.sg.ouput-sg-id, "web-server", null)]
        }
       ]      
    }
  }
}

module "ec2" {
  source = "./module/ec2"
  
  ami = "ami-068257025f72f470d"
  pub-snet = lookup(module.network.pub-snet-id, "s1", null).id
  sg = lookup(module.sg.ouput-sg-id, "web-server", null)

  sgn = lookup(module.network.pub-snet-id, "s1", null).id
  sgn2 = lookup(module.network.pub-snet-id, "s2", null).id
  az = "ap-south-1a"
  sgrds = lookup(module.sg2.ouput-sg-id, "rds-db", null)
  username = "admin"
  password = "Password123"
  dbname = "myname"
}

# output "db-port" {
#   value = module.ec2.db-dns
#}
# output "db-host" {
#   value = module.ec2.db-host
# }