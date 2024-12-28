variable "vpc_cidr" {
  default = "10.0.0.0/24"
}
#cidr block for 1st subnet
variable "subnet1_cidr" {
  default = "10.0.1.0/24"
}
#cidr block for 2nd subnet
variable "subnet2_cidr" {
  default = "10.0.2.0/24"
}

#cidr block for 3rd private subnet
variable "subnet3_cidr" {
  default = "10.0.3.0/24"
}
# existing VPC we created manually
variable "main_vpc" {
  default = "vpc-0d3d808c427d60b4a"
}

variable "qwatt_beta_server" {
  default = "i-0d639830ca1dbe1a4"
}
