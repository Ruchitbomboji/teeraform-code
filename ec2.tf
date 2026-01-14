resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "bastion_key" {
  content          = tls_private_key.bastion.private_key_pem
  filename         = "${path.module}/bastion_private_key.pem"
  file_permission  = "0600"
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion.public_key_openssh
}

data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["amazon"] 
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.my_ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = aws_key_pair.bastion_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.main_sg.id]

  tags = {
    Name = "Bastion"
  }
}

resource "aws_instance" "private_server" {
  ami                    = data.aws_ami.my_ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_1.id
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.main_sg.id]

  tags = {
    Name = "PrivateServer"
  }

  depends_on = [aws_nat_gateway.nat]
}
