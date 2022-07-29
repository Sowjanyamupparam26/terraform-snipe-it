locals{
  vpc_id           = "vpc-066eb979247316a4c"
  subnet_id        = "subnet-009504e4401e7b514"
  ssh_user         = "ubuntu"
  key_name         = "terra"
  private_key_path = "/root/terraform-snipe-it/tasks/terra.pem"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg" {
  name   = "terraform-sg"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "intro" {
  ami                         = "ami-052efd3df9dad4825"
  subnet_id                   = "subnet-009504e4401e7b514"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.sg.id]
  key_name                    = local.key_name

  provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.intro.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.intro.public_ip}, --private-key ${local.private_key_path} main.yml"
  }
}