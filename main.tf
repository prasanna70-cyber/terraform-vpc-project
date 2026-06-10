# -----------------------
# VPC
# -----------------------

resource "aws_vpc" "main_vpc" {

  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}

# -----------------------
# Internet Gateway
# -----------------------

resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# -----------------------
# Public Subnet AZ1
# -----------------------

resource "aws_subnet" "public_subnet_az1" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = var.public_subnet1_cidr

  availability_zone = var.availability_zone1

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az1"
  }
}

# -----------------------
# Public Subnet AZ2
# -----------------------

resource "aws_subnet" "public_subnet_az2" {

  vpc_id = aws_vpc.main_vpc.id

  cidr_block = var.public_subnet2_cidr

  availability_zone = var.availability_zone2

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-az2"
  }
}

# -----------------------
# Public Route Table
# -----------------------

resource "aws_route_table" "public_rt" {

  vpc_id = aws_vpc.main_vpc.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# -----------------------
# Route Table Associations
# -----------------------

resource "aws_route_table_association" "public_assoc_az1" {

  subnet_id = aws_subnet.public_subnet_az1.id

  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_az2" {

  subnet_id = aws_subnet.public_subnet_az2.id

  route_table_id = aws_route_table.public_rt.id
}

# -----------------------
# Security Group
# -----------------------

resource "aws_security_group" "web_sg" {

  name = "web-sg"

  vpc_id = aws_vpc.main_vpc.id

  ingress {

    description = "HTTP"

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {

    description = "SSH"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# -----------------------
# S3 Bucket
# -----------------------

resource "aws_s3_bucket" "bucket" {

  bucket = "terraform-20309"
}

# -----------------------
# EC2 Web Server 1
# -----------------------

resource "aws_instance" "webserver1" {

  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet_az1.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("userdata.sh")

  tags = {
    Name = "webserver1"
  }
}

# -----------------------
# EC2 Web Server 2
# -----------------------

resource "aws_instance" "webserver2" {

  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public_subnet_az2.id

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = file("userdata1.sh")

  tags = {
    Name = "webserver2"
  }
}

# -----------------------
# Application Load Balancer
# -----------------------

resource "aws_lb" "alb" {

  name = "web-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [aws_security_group.web_sg.id]

  subnets = [
    aws_subnet.public_subnet_az1.id,
    aws_subnet.public_subnet_az2.id
  ]
}

# -----------------------
# Target Group
# -----------------------

resource "aws_lb_target_group" "tg" {

  name = "web-tg"

  port = 80

  protocol = "HTTP"

  vpc_id = aws_vpc.main_vpc.id

  health_check {

    path = "/"

    port = "traffic-port"
  }
}

# -----------------------
# Target Attachments
# -----------------------

resource "aws_lb_target_group_attachment" "web1" {

  target_group_arn = aws_lb_target_group.tg.arn

  target_id = aws_instance.webserver1.id

  port = 80
}

resource "aws_lb_target_group_attachment" "web2" {

  target_group_arn = aws_lb_target_group.tg.arn

  target_id = aws_instance.webserver2.id

  port = 80
}

# -----------------------
# Listener
# -----------------------

resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.tg.arn
  }
}
