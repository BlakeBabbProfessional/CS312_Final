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

resource "null_resource" "restart" {

  connection {
    type     = "ssh"
    user     = "ec2-user"
	private_key = file("ssh-key.pem")
    host     = aws_instance.app_server.public_ip
  }

  provisioner "remote-exec" {
  	inline = [
	  "echo \"stopping server...\"",
      "sudo systemctl stop serverctl",
	  "sleep 5",
	  "sudo /usr/sbin/shutdown -r 1"
	]
  }

  triggers = {
    always_run = "${timestamp()}"
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
  public_key = file("ssh-key.pem.pub")
}
