variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_name" {
  type        = string
  description = "vpc_name"
}

variable "lb_name" {
  type        = string
  description = "load balancer name"
}

variable "azs" {
  type=list(string)
  description = "Map for subnets"
}

variable "cidr_block" {
  type    = string
  description = "cidr for my tp2"
}

variable "cidr_dest" {
  type    = string
  description = "cidr for all"
}

/*variable "public_key1"{
  type    = string
  description = "public key"
}
*/
