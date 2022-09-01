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
        self = false
        to_port = 80
         },
        {
        cidr_blocks = ["0.0.0.0/0"]
        from_port = 22
        protocol = "tcp"
        self = false
        to_port = 22
         }
       ]      
    }
    "rds-db" = {
      description = "rsd inbound"
      name = "rds-db"
      vpc_id = module.network.vpc-id
      ingress_rules = [ 
        {
        cidr_blocks = ["10.0.0.0/20"]
        from_port = 3306
        protocol = "tcp"
        self = false
        to_port = 3306
        }
       ]      
    }
  }
}

module "ec2" {
  source = "./module/ec2"
  sg = lookup(module.sg.ouput-sg-id, "web-server", null)
  ami = "ami-068257025f72f470d"
  pub-snet = lookup(module.network.pub-snet-id, "s1", null).id
  az = "ap-south-1a"
  
}

