# Creating VPC using Terraform

## Features
- Easy to deply.
- Subnets are created through automation.

## Prerequisites for this project
- IAM user with programmatic access.
- erraform should be installed locally.
- Good knowledge in the concept of vpc, ec2 and networking.

## Setting up Terraform in the local machine
- Please click [here](https://developer.hashicorp.com/terraform/downloads) to get knowledge on how to install Terraform.

## Creating Terraform Configurations
### Create a file variable.tf
```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "project_name" {}
variable "instance_ami" {}
variable "instance_type" {}
```

### Create a provider.tf file 
```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```

Go to the local directory to save the tfstate files and initiate the Terraform working directory using the below command.

```
terraform init
```

Let us create the main.tf file as below.
 > Create VPC
 ```sh
 resource "aws_vpc" "myplanet" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name    = var.project
    Project = var.project
  }
}
```

> Create Internet Gateway
```sh
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myplanet.id
  
  tags = {
    Name = var.project
    Project = var.project
  }
}
```

> To Gather All Subnet Name
```sh
data "aws_availability_zones" "available" {
  state = "available"
}
```

> To Create Public Subnet 1 
```sh
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 3)
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}
```

> To Create Public Subnet 2 
```sh
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 1)
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public2"
    Project = var.project
  }
}
```

> To Create Public Subnet 3
```sh
resource "aws_subnet" "public3" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 2)
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public3"
    Project = var.project
  }
}
```

> To Create Private Subnet 1
```sh
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 3)
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}
```

> To Create Private Subnet 2
```sh
resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 4)
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private2"
    Project = var.project
  }
}
```

> To Create Private Subnet 3
```sh
resource "aws_subnet" "private3" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 5)
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-private3"
    Project = var.project
  }
}
```

> Creating Public Route Table
```sh
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.myplanet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-public"
    Project = var.project
  }  
}
```

> Associate Public Subnets to IGW
```sh
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rtb.id
}
```
```sh
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rtb.id
}
```
```sh
resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public-rtb.id
}
```

> Creating Elastic IP for NAT GateWay
```sh
resource "aws_eip" "nat" {
  vpc      = true

  tags = {
    Name    = "${var.project}-nat-gw"
    Project = var.project
  }
}
```

> Create NAT GateWay
```sh
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}
```

> Create Private Route Table
```sh
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.myplanet.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-private"
    Project = var.project
  }
}
```

> Associate Private Subnets to NAT GateWay
```sh
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-rtb.id
}
```
```sh
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-rtb.id
}
```
```sh
resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private-rtb.id
}
```

> To import the public key to AWS setup
```sh
resource "aws_key_pair" "mykey" {
  key_name   = "${var.project}-key"
  public_key = file("ec2key.pub")

  tags = {
    Name    = var.project
    Project = var.project
  }
}
```

> Creating Security Group for Jump Host
```sh
resource "aws_security_group" "jumphost" {
  name_prefix = "jumphost"
  description = "Allow 22 traffic"
  vpc_id      = aws_vpc.myplanet.id

  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project}-jumphost"
    Project = var.project
  }
}
```

> Create Security Group for Frontend Server
```sh
resource "aws_security_group" "frontend" {
  name_prefix = "frontend"
  description = "Allow 80 and 443 traffic"
  vpc_id      = aws_vpc.myplanet.id
    
  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.jumphost.id ]
  }

ingress {
    description      = ""
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project}-frontend"
    Project = var.project
  }
}
```

> Creating Security Group for Backend server
```sh
resource "aws_security_group" "backend" {
  name_prefix = "bakend"
  description = "Allow 3306 traffic"
  vpc_id      = aws_vpc.myplanet.id
    
  ingress {
    description      = ""
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [ aws_security_group.jumphost.id ]
  }

  ingress {
    description      = ""
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "${var.project}-backend"
    Project = var.project
  }
}
```

> Create Jump Host Server
```sh 
resource "aws_instance" "jumphost" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = aws_key_pair.mykey.id
  vpc_security_group_ids    = [ aws_security_group.jumphost.id ]
  subnet_id		    = aws_subnet.public1.id

  tags = {
    Name    = "${var.project}-jumphost"
    Project = var.project
  }
}
```

> Create Frontend Server
```sh
resource "aws_instance" "frontend" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = aws_key_pair.mykey.id
  vpc_security_group_ids    = [ aws_security_group.frontend.id ]
  subnet_id                 = aws_subnet.public2.id

  tags = {
    Name    = "${var.project}-frontend"
    Project = var.project
  }
}
```

> Create Backend Server
```sh
resource "aws_instance" "backend" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = aws_key_pair.mykey.id
  vpc_security_group_ids    = [ aws_security_group.backend.id ]
  subnet_id                 = aws_subnet.private2.id

  tags = {
    Name    = "${var.project}-backend"
    Project = var.project
  }
}
```

#### Lets validate the terraform files using
```sh
terraform validate
```
#### Lets plan the architecture and verify once again.
```sh
terraform plan
```
#### Lets apply the above architecture to the AWS.
```sh
terraform apply
```
