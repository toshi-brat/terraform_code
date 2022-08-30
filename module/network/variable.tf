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
  default = false
}

#count = var.is_nat_required ? 1 : 0