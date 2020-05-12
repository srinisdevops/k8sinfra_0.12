provider "aws" {
   region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "clisrimul"
    key    = "k8smod/terraform.tfstate"
    region = "us-east-2"
  }
}
#resource "aws_security_group" "allow_ssh" {
#  name = "sg_Ansible"
#  description = "Allow ssh inbound traffic"
#  ingress {
#      from_port = 22
#      to_port = 22
#      protocol = "tcp"
#      cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#      from_port = 443
#      to_port = 443
#      protocol = "tcp"
#      cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#      from_port = 80
#      to_port = 80
#      protocol = "tcp"
#      cidr_blocks = ["0.0.0.0/0"]
# }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
module "k8sMaster" {
  source = "../../modules/ec2"
  amiid = "${lookup(var.amiid, var.region)}"
  instance_type = var.instance_type
  instance_count = var.instance_count
  vpc_security_group_ids = var.security_group
  instance_tags ="${element(var.instance_tags,0)}"
  
  key_name = "${var.key_name}"

#  user_data = "${file("master.sh")}"
 }

output "master_public_ip" {
 #value = "${module.k8sMaster.k8s_public_ip}"
  value = "${formatlist("%v", module.k8sMaster.*.k8s_public_ip)}"
}
module "k8shost" {
  source = "../../modules/ec2"
  amiid = "${lookup(var.amiid, var.region)}"
  instance_type = var.hostinstance_type
  instance_count = var.hostinstance_count
  vpc_security_group_ids = var.security_group
  instance_tags ="${element(var.instance_tags,1)}"
  key_name = "${var.key_name}"

#  user_data = "${file("host.sh")}"
 }

output "public_ip" {
 #value = "${module.k8shost.k8s_public_ip}"
  value = "${formatlist("%v", module.k8shost.*.k8s_public_ip)}"
}

resource "null_resource" "myPublicIps" {
#count = var.instance_count

provisioner "local-exec" {
command =  "echo 'masters' > hosts1"
}
provisioner "local-exec" {
 command = "echo '${element(module.k8sMaster.k8s_public_ip.*,0)}' >> hosts1"
 on_failure = continue
   }
provisioner "local-exec" {
    command=  "echo 'workers' >> hosts1"
}
provisioner "local-exec" {
     command = "echo '${element(module.k8shost.k8s_public_ip.*,0)}' >> hosts1"
 }
provisioner "local-exec" {
 command = "echo '${element(module.k8shost.k8s_public_ip.*,1)}' >> hosts1"
 on_failure = continue
 }
}
