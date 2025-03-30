#VPC code
resource "aws_vpc" "utc-app1" {
  cidr_block           = "172.120.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "utc-app1"
    env  = "Dev"
    Team = "Devops"
  }
}

#iinternet gateway
resource "aws_internet_gateway" "utc-igw" {
  vpc_id = aws_vpc.utc-app1.id
  tags = {
    Name = "utc-app1"
    env  = "Dev"
    Team = "Devops"
  }
}
#Elastic IP
resource "aws_eip" "utc-eip" {

  tags = {
    Name = "utc-eip"
    env  = "Dev"
    Team = "Devops"
  }
}

#Nat gateway
resource "aws_nat_gateway" "utc-natgw" {
  allocation_id = aws_eip.utc-eip.id
  subnet_id     = aws_subnet.utc-public-sub1.id
  tags = {
    Name = "utc-Natgw"
    env  = "Dev"
    Team = "Devops"
  }
}

#subnet public 1
resource "aws_subnet" "utc-public-sub1" {
  vpc_id                  = aws_vpc.utc-app1.id
  map_public_ip_on_launch = true
  cidr_block              = "172.120.1.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "public-sub1"
    env  = "Dev"
    Team = "Devops"
  }
}
#Public subnet 2
resource "aws_subnet" "utc-public-sub2" {
  vpc_id                  = aws_vpc.utc-app1.id
  map_public_ip_on_launch = true
  cidr_block              = "172.120.2.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "public-sub2"
    env  = "Dev"
    Team = "Devops"
  }
}
#private subnet 1
resource "aws_subnet" "utc-private-sub1" {
  vpc_id            = aws_vpc.utc-app1.id
  cidr_block        = "172.120.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-sub1"
    env  = "Dev"
    Team = "Devops"
  }
}
#private subnet 2
resource "aws_subnet" "utc-private-sub2" {
  vpc_id            = aws_vpc.utc-app1.id
  cidr_block        = "172.120.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-sub2"
    env  = "Dev"
    Team = "Devops"
  }
}
#create routetable  for utc
resource "aws_route_table" "utc-rt" {
  vpc_id = aws_vpc.utc-app1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.utc-igw.id
  }
  tags = {
    Name = "utc-rt"
    env  = "Dev"
    Team = "Devops"
  }
}
#public subnet1 association
resource "aws_route_table_association" "public-sub1" {
subnet_id  =  aws_subnet.utc-public-sub1.id
route_table_id = aws_route_table.utc-rt.id
}
  #public subnet2 association
resource "aws_route_table_association" "public-sub2" {
subnet_id  =  aws_subnet.utc-public-sub2.id
route_table_id = aws_route_table.utc-rt.id
}

#create security groups for utc app1
resource "aws_security_group" "utc-sg" {
  name        = "utc-sg"
  description = "Allow ssh ,HTTP on 22,80 and 8080"
  vpc_id      = aws_vpc.utc-app1.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "utc-sg"
    env  = "Dev"
    Team = "Devops"
  }
}
#create a key pair
resource "aws_key_pair" "utc-key" {
  key_name   = "utc-key"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "utc-key"
    env  = "Dev"
    Team = "Devops"
  }
}


#create an ec2 instance
resource "aws_instance" "utc-app1" {
  ami                    = "ami-05b10e08d247fb927"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.utc-public-sub1.id
  vpc_security_group_ids = [aws_security_group.utc-sg.id]
  key_name               = aws_key_pair.utc-key.key_name

  #user data
  user_data = <<-EOF
  #!/bin/bash
   yum update -y
   groupadd docker
   useradd John -aG docker 
   yum install git unzip wget httpd -y
   systemctl start httpd
   systemctl enable httpd
   cd /opt
   wget https://github.com/kserge2001/web-consulting/archive/refs/heads/dev.zip
   unzip dev.zip
   cp -r /opt/web-consulting-dev/* /var/www/html

EOF

  tags = {
    Name   = "utc-app1"
    env    = "Dev"
    Team   = "Devops"
    create = "Eyuyun"
  }

}

#create an EBS volume
resource "aws_ebs_volume" "utc-ebs" {
  availability_zone = "us-east-1a"
  size              = 20
  tags = {
    Name = "utc-ebs"
    env  = "Dev"
    Team = "Devops"
  }
}
#EBS volume attachment
resource "aws_volume_attachment" "utc-vol-attach" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.utc-ebs.id
  instance_id = aws_instance.utc-app1.id
}

#creating a dns record
resource "aws_route53_record" "utc-dns" {
  zone_id = "Z056635211G6YQMLXKGJ2"  
  name    = "eyuyun.org" 
  type    = "A"
  ttl     = 300

  records = [aws_instance.utc-app1.public_ip] 
}
