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

}
