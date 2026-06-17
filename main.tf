provider "aws" {
  region = "ap-southeast-2"
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "main-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main-igw"
  }
}

# Create a route table
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
}

resource "aws_route_table_association" "main_rta" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# EC2 Instance with Jenkins installed via user_data
resource "aws_instance" "jenkins_server" {
  ami           = "ami-06259b63260eddc13" # Ubuntu AMI (example, update for your region)
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.main_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y openjdk-11-jdk
              wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
              sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              apt-get update -y
              apt-get install -y jenkins
              systemctl enable jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "jenkins-server"
  }
}

