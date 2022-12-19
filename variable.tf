variable "region" {
  default = "ap-south-1"
}

variable "access_key" {
  description = "my access key"
  default     = "IAM access key"
}

variable "secret_key" {
  description = "my secret key"
  default     = "IAM Secret Key"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "project" {
  default = "myplanet"
}

variable "ami_id" {
  default = "ami-074dc0a6f6c764218"
}

variable "instance_type" {
  default = "t2.micro"
}
