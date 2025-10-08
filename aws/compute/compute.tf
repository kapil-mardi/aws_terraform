variable "ami" {}
variable "size" {
  default = "t3.micro"
}
variable "subnet_id" {}
variable "security_groups" {
  type = list(any)
}
variable "server_name" {
  type = string
}

variable "user_commands" {
  default = ""
}

resource "aws_instance" "ec2_server" {
  ami                    = var.ami
  instance_type          = var.size
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_groups
  user_data = var.user_commands

  tags = {
    "Name"        = var.server_name
  }
}

output "public_ip" {
  value = aws_instance.ec2_server.public_ip
}

output "public_dns" {
  value = aws_instance.ec2_server.public_dns
}