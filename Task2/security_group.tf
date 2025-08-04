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

resource "aws_security_group" "k3s_sg" {
  name        = "k3s-sg"
  description = "Allow k3s cluster internal communication"
  vpc_id      = aws_vpc.main.id

  # Kubernetes API Server
  ingress {
    description = "k3s API (6443)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  # Flannel VXLAN
  ingress {
    description = "Flannel VXLAN (8472)"
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
  }

  # Kubelet metrics
  ingress {
    description = "Kubelet metrics (10250)"
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  # SSH from bastion (опционально, если хочешь доступ по SSH)
  ingress {
    description = "SSH from Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Разрешаем выход из приватной подсети (нужно для pull docker images, и т.д.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}

resource "aws_security_group" "all_nodes" {
  name        = "all-nodes-internal"
  description = "Allow full internal communication"
  vpc_id      = aws_vpc.main.id

  # Входящий весь TCP/UDP трафик от себя же
  ingress {
    description = "All internal TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }
  ingress {
    description = "All internal UDP"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
  }

  # Исходящий трафик на всё
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "all-nodes-sg"
  }
}