resource "aws_instance" "bastion_host_ec2_instance" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public[0].id
  vpc_security_group_ids  = [aws_security_group.bastion_sg.id,aws_security_group.all_nodes.id]
  key_name                = "MyServer1"
  root_block_device {
    volume_size = 10           # Размер в гигабайтах
    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
    delete_on_termination = true
  }
  tags = {
    Name = "${var.project_name}-bastion"
  }
}