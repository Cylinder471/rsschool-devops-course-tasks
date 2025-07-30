resource "aws_security_group" "bastion_sg" { 
    name = "bastion-sg" 
    description = "Allow SSH and outbound traffic" 
    vpc_id = aws_vpc.main.id
    ingress { 
        from_port = 22 
        to_port = 22 
        protocol = "tcp" 
        cidr_blocks = ["0.0.0.0/0"] # Ограничь доступ только нужным IP в продакшене 
    }

    egress { 
        from_port = 0 
        to_port = 0 
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"] 
    } 
}

resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "PrivateRouteTableAZ1"
  }
}


resource "aws_route" "private_default_route_az1" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.bastion_host_ec2_instance.primary_network_interface_id
}
resource "aws_security_group" "private_sg" { 
    name = "private-sg" 
    description = "Allow outbound to Bastion" 
    vpc_id = aws_vpc.main.id
      ingress { 
        from_port = 22 
        to_port = 22 
        protocol = "tcp" 
        cidr_blocks = ["${aws_instance.bastion_host_ec2_instance.private_ip}/32"] # Ограничь доступ только нужным IP в продакшене 
    }
    egress { 
        from_port = 0 
        to_port = 0 
        protocol = "-1" 
        cidr_blocks = ["${aws_instance.bastion_host_ec2_instance.private_ip}/32"] # Трафик только к Bastion 
    } 
}