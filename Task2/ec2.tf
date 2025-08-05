resource "aws_instance" "in_private1" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private[0].id
  vpc_security_group_ids  = [aws_security_group.all_nodes.id, aws_security_group.k3s_sg.id]
  key_name                = "MyServer1"
  root_block_device {
    volume_size = 10           # Размер в гигабайтах
    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
    delete_on_termination = true
  }
  user_data = <<-EOF
              #!/bin/bash
              TOKEN=$(aws ssm get-parameter --name "/edu/${var.project_name}/k3s/token" --with-decryption --query "Parameter.Value" --output text --region ${var.aws_region})
              curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' K3S_TOKEN="$${TOKEN}" K3S_KUBECONFIG_MODE='644' sh -s -
              EOF
  tags = {
    Name = "${var.project_name}-private1"
  }
}
data "aws_caller_identity" "current" {}
resource "aws_instance" "in_private2" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private[1].id
  vpc_security_group_ids  = [aws_security_group.all_nodes.id, aws_security_group.k3s_sg.id]
  key_name                = "MyServer1"
  root_block_device {
    volume_size = 10           # Размер в гигабайтах
    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
    delete_on_termination = true
  }
  user_data = <<-EOF
              #!/bin/bash
              TOKEN=$(aws ssm get-parameter --name "/edu/${var.project_name}/k3s/token" --with-decryption --query "Parameter.Value" --output text --region ${var.aws_region})
              K3S_URL="https://${aws_instance.in_private1.private_ip}:6443"
              curl -sfL https://get.k3s.io | K3S_URL="$K3S_URL" K3S_TOKEN="$TOKEN" sh -
              EOF
  tags = {
    Name = "${var.project_name}-private2"
  }
}
#resource "aws_instance" "in_public2" {
#  ami                     = data.aws_ami.latest_ubuntu.id
#  instance_type           = var.instance_type
#  subnet_id               = aws_subnet.public[1].id
#  vpc_security_group_ids  = [aws_security_group.private_sg.id]
#  key_name                = "MyServer1"
#  root_block_device {
#    volume_size = 10           # Размер в гигабайтах
#    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
#    delete_on_termination = true
#  }
#  tags = {
#    Name = "${var.project_name}-public2"
#  }
#}