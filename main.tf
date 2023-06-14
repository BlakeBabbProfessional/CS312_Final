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

  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        echo "Restarting instance with id ${aws_instance.app_server.id}"
        # aws ec2 reboot-instances --instance-ids ${aws_instance.app_server.id}
        # To stop instance
        aws ec2 stop-instances --instance-ids ${aws_instance.app_server.id}
        echo "Rebooted"
     EOT
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
