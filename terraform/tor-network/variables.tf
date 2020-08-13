variable "region" {
  default = ["ap-southeast-2"]
}

variable "servers_per_az" {
  default = 1
}

variable "instance_type" {
  default = "t3.micro"
}
