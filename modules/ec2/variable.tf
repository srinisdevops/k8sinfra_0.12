variable "region" {
  default = "us-east-2"
}
variable "amiid" {
  type = "string"
  description = "You may added more regions if you want"
}

variable "instance_count" {
 type = number
}
variable "instance_type" {
  type = "string"
}
variable "key_name" {
  type = "string"
  description = "the ssh key to be used for the EC2 instance"
}

variable "instance_tags" {
  type = "string"
}
variable "vpc_security_group_ids" {
 type = "string"
}
#variable "user_data" {
# type = "string"
#}   
