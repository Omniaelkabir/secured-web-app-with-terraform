variable "vpc_cidr" {}
variable "vpc_name" {}
variable "subnet_cidr" {
  type = list(any)
}
variable "zone1" {}
variable "zone2" {}
variable "cidr_from_anywhere" {}
variable "ami_id" {}
variable "vm_type" {}
