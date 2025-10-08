resource "aws_network_acl" "ssh_http_public" {
    vpc_id = aws_vpc.default_vpc.id

    ingress {
        protocol = "tcp"
        rule_no = 1
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 80
        to_port = 80
    }

    ingress {
        protocol = "tcp"
        rule_no = 2
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 443
        to_port = 443
    }

    ingress {
        protocol = "tcp"
        rule_no = 3
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 22
        to_port = 22
    }

    egress {
        protocol = "-1"
        rule_no = 4
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    tags = {
      Name = "SSH and HTTP NACL"
    }
  
}


output "ssh_http_nacl" {
  value = aws_network_acl.ssh_http_public.id
}