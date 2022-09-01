variable "cidr" {}
variable "app_name" {}

variable "pub-snet-details" {
    type = map(object({
    cidr_block          = string
    availability_zone   = string
}))
}

variable "pri-snet-details" {
    type = map(object({
    cidr_block          = string
    availability_zone   = string
}))
}

variable "is_nat_required" {
  
}

variable "nat-pub-id" {

}
