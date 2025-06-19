resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"
    Terraform   = "true"
    Environment = var.project_name
  }
}
