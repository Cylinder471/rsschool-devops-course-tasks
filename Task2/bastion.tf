resource "aws_instance" "bastion_host_ec2_instance" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public[0].id
  vpc_security_group_ids  = [aws_security_group.bastion.id]
  key_name                = "MyServer1"

  tags = {
    Name = "${var.project_name}-bastion"
  }
}
resource "aws_instance" "in_private1" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private[0].id
  vpc_security_group_ids  = [aws_security_group.internal.id]
  key_name                = "MyServer1"

  tags = {
    Name = "${var.project_name}-private1"
  }
}
resource "aws_instance" "in_private2" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.private[1].id
  vpc_security_group_ids  = [aws_security_group.internal.id]
  key_name                = "MyServer1"

  tags = {
    Name = "${var.project_name}-private2"
  }
}
resource "aws_instance" "in_public2" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.instance_type
  subnet_id               = aws_subnet.public[1].id
  vpc_security_group_ids  = [aws_security_group.internal.id]
  key_name                = "MyServer1"

  tags = {
    Name = "${var.project_name}-public2"
  }
}