resource "aws_vpc" "default_vpc" {

  //cider block with 16 bit subnet for master vpc
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "first vpc"
  }

}

//----------- Public subnet ---------------//

/*
  VPC
    Public Subnet
  IG
  RT
    Public Subnet id
    destination cidr 0.0.0.0/0 --> IG
*/

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    az_for = "ap-south-1a"
    Name   = "public subnet 1"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "internet gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public RT"
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}


//----------- Private subnet ---------------//
/*
  VPC
    Private Subnet
    Public Subnet
      NAT -> requires elastic IP
  IG
  RT
    Private Subnet id
  ROUTE
    RT Id
    destination cidr 0.0.0.0/0 --> NAT --> Public Subnet --> RT --> IG
*/

resource "aws_subnet" "private_subnet_1" {

  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    az_for = "ap-south-1b"
    Name   = "private subnet 1"
  }

}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.default_vpc.id
  tags = {
    Name = "Private RT"
  }
}

// NAT Gatway to connect to the Internet from private subnet
// We need to put NAT inside Public subnet and from private RT 
// redirect all outbound network requests to the NAT
// Private Subnet --> Private RT --> NAT --> IG through Public Subnet
// Need elastic IP for NAT
# resource "aws_eip" "NAT_IP" {
#   domain = "vpc"

#   tags = {
#     Name = "NAT eip"
#   }
# }

# resource "aws_nat_gateway" "nat_gateway" {
#   allocation_id = aws_eip.NAT_IP.id
#   subnet_id     = aws_subnet.public_subnet_1.id

#   depends_on = [aws_internet_gateway.internet_gateway]

#   tags = {
#     Name = "Nat gatway Private Subnet"
#   }
# }

# resource "aws_route" "private_rt_to_nat" {
#   route_table_id         = aws_route_table.private_rt.id
#   nat_gateway_id         = aws_nat_gateway.nat_gateway.id
#   destination_cidr_block = "0.0.0.0/0"
# }

# resource "aws_route_table_association" "private_route_association" {
#   subnet_id = aws_subnet.private_subnet_1.id
#   route_table_id = aws_route_table.private_rt.id
# }


//----------------Security groups-----------------//

resource "aws_security_group" "public_security_group" {
  name = "Allow ssh and http"
  vpc_id = aws_vpc.default_vpc.id
  description = "Allow ssh and http"


  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 22
    to_port = 22
    description = "Allow SSH"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 80
    to_port = 80
    description = "Allow http"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
    from_port = 443
    to_port = 443
    description = "Allow https"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
    from_port = 0
    to_port = 0
    description = "Allow everything outgoing"
  }

  tags = {
    Name = "Public security group"
  }
}

resource "aws_network_acl_association" "ssh_http_subnet_public" {
  network_acl_id = aws_network_acl.ssh_http_public.id
  subnet_id = aws_subnet.public_subnet_1.id
}

output "vpc_id" {
    value = aws_vpc.default_vpc.id
}

output "public_subnet_id" {
    value = aws_subnet.public_subnet_1.id
}

output "public_security_groups" {
  value = aws_security_group.public_security_group.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet_1.id
}