
output "rendered_user_data" {
  value = templatefile("${path.module}/k3s_master.sh", {
    hostname   = "${var.project_name}-k3s-master-node"
    project    = var.project_name
    aws_region = var.aws_region
  })
}
resource "aws_instance" "in_private1" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = "t3.small"
  subnet_id               = aws_subnet.private[0].id
  depends_on = [ aws_nat_gateway.natgw ]
  vpc_security_group_ids  = [aws_security_group.all_nodes.id, aws_security_group.k3s_sg.id]
  key_name                = "MyServer1"
  iam_instance_profile    = aws_iam_instance_profile.k3s_worker_profile.name
  root_block_device {
    volume_size = 10           # Размер в гигабайтах
    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
    delete_on_termination = true
  }
  user_data = base64encode(templatefile("${path.module}/k3s_master.sh", {
    hostname   = "${var.project_name}-k3s-master-node"
    project    = var.project_name
    aws_region = var.aws_region
  }))
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
  iam_instance_profile    = aws_iam_instance_profile.k3s_worker_profile.name
  root_block_device {
    volume_size = 10           # Размер в гигабайтах
    volume_type = "gp3"        # Тип диска (например, gp2, gp3, io1 и т.д.)
    delete_on_termination = true
  }
  user_data = base64encode(templatefile("${path.module}/k3s_slave.sh", {
    hostname   = "${var.project_name}-k3s-slave-node"
    project    = var.project_name
    aws_region = var.aws_region
    master_ip  = aws_instance.in_private1.private_ip
  }))

  tags = {
    Name = "${var.project_name}-private2"
  }
  depends_on = [ aws_instance.in_private1 ]
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