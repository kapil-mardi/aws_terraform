module "vpc" {
  source = "../aws/network"
}

module "ami" {
  source = "../aws/compute/data"
}

module "compute_resource_public_1" {
  source          = "../aws/compute"
  security_groups = [module.vpc.public_security_groups]
  subnet_id       = module.vpc.public_subnet_id
  server_name     = "Public server"
  ami             = module.ami.ubuntu_ami
  user_commands   = <<-EOF
                        #!/bin/bash
                        # Update system packages
                        apt-get update -y

                        # Install Apache
                        apt-get install -y httpd

                        # Create a simple web page
                        echo "<h1>Hello from EC2 $(hostname -f)</h1>" > /var/www/html/index.html

                        # Start and enable Apache
                        systemctl start httpd
                        systemctl enable httpd
                    EOF
}

module "compute_resource_privaate_1" {
  source          = "../aws/compute"
  security_groups = [module.vpc.public_security_groups]
  subnet_id       = module.vpc.private_subnet_id
  server_name     = "Private server"
  ami             = module.ami.ubuntu_ami
}