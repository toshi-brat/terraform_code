variable "s1" {
  default = {
    s1 = {
        name = "abc"
        gn_ipv6_address_on_creation                = false
        
    },
    s2 = {
        name = "xyz"
        gn_ipv6_address_on_creation                = false
    }
  }
}


output "v" {
 value = [for v in var.s1: v]
}
output b {
    value = [for v in var.s1: v.name]
}