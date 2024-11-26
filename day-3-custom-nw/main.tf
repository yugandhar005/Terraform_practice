#create vpc
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "CustomVPC"
  }
}

#create subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "PrivateSubnet"
  }
}

#create internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "CustomIGW"
  }
}

#create route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


#Create Security Group
resource "aws_security_group" "custom_sg" {
  name        = "custom-security-group"
  description = "Security group for web server"
  vpc_id      = aws_vpc.custom_vpc.id  # Replace with your VPC ID

  # Inbound Rules
  ingress {
    description      = "Allow HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all IPs
  }

  ingress {
    description      = "Allow HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Allow all IPs
  }

  ingress {
    description      = "Allow SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["49.156.151.238/32"]  # Restrict to your IP or subnet
  }

  ingress {
    description      = "Allow SSH traffic"
    from_port        = 25
    to_port          = 25
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Restrict to your IP or subnet
  }

  # Outbound Rules (allow all by default)
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # All protocols
    cidr_blocks      = ["0.0.0.0/0"]
  }

  
}

#Create EC2
resource "aws_instance" "web_server" {
  ami           = "ami-012967cc5a8c9f891" 
  instance_type = "t2.micro"
  key_name = "awsaws"
  subnet_id = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.custom_sg.id]  # Reference by name
  

  tags = {
    Name = "WebServer"
  }
}

# Create an Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NATGateway"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate the route table with the private subnet
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

