terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-2"
}

provider "random" {}

resource "random_pet" "name" {}

resource "aws_instance" "app_server" {
  ami           				= "ami-080f7286ffdf988ee"
  instance_type 				= "t2.small"
  user_data						= file("init_script.sh")
  user_data_replace_on_change 	= true
  vpc_security_group_ids 		= [aws_security_group.web-sg.id]
  associate_public_ip_address 	= true
  key_name 						= "ssh-key"

  tags = {
    Name = random_pet.name.id
  }
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.name.id}-sg"
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port	= 22
	to_port		= 22
	protocol	= "tcp"
	cidr_blocks	= ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "instance" {
  key_name	= "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOaS5bWZ47rcUHtimG4kGg0PISCTSpLTjMt028ufQjzWcREvABRPNVPX3JU03bJKPg1vSPZhAy42B7KE7eVxh85hOdkVI+zZ14qu1o3HIlKKy29lpVTDCGJp57pn783QMDLO9DdVOwUzwdJo5qbkW/gayr5f10PpV48gSSFoMs+pzaQicWN7iXkq9Ai0WOXhJPIIg0P5Rpi02oLloBklWqqEv47ItdIfuirh00fR+PobDPpEJpwMw4GxSZogQl9VN3riZc3AjS/vCf4o0t0F7gbBJxhFgZRF3E1qN2y57iw+CKofyABCdxS9qwGpYUcB4irPJ0gzfL44punLIBvb1QMoc8ndO0WD10ls+xIqQ7SmjY2fupxEwRQNpdfTpXK6qLJPg5yPrcwgX3KfjFaehJha8Y0dkstz6JBN7dOOMOXRvz9xPdECz/rCjgVaIwgnE//0JPJTvCA7VJJHO92nTCj6E1yBMMRU9Su8G9bdZHYcfoXnEsKB6s73FAIIoq3/M= blakebabb@10-249-71-185.wireless.oregonstate.edu"
}
