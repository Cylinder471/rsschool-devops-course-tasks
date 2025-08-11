resource "aws_instance" "bastion_host_ec2_instance" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public[0].id
  vpc_security_group_ids  = [aws_security_group.bastion_sg.id,aws_security_group.all_nodes.id]
  key_name                = "MyServer1"
  iam_instance_profile    = aws_iam_instance_profile.k3s_worker_profile.name
  root_block_device {
    volume_size = 10           # Размер в гигабайтах
    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
    delete_on_termination = true
  }
  depends_on = [ aws_instance.in_private2 ]
  user_data = base64encode(templatefile("${path.module}/bastion.sh", {
    hostname   = "${var.project_name}-bastion"
    project    = var.project_name
    aws_region = var.aws_region
    master_ip  = aws_instance.in_private1.private_ip
  }))
  tags = {
    Name = "${var.project_name}-bastion"
  }
}