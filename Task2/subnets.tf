resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element([var.public_subnet_1_cidr, var.public_subnet_2_cidr], count.index)
  availability_zone       = element([var.availability_zone_1, var.availability_zone_2], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "public-subnet-${count.index + 1}"
    Terraform   = "true"
    Environment = "rsschool"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = element([var.private_subnet_1_cidr, var.private_subnet_2_cidr], count.index)
  availability_zone = element([var.availability_zone_1, var.availability_zone_2], count.index)

  tags = {
    Name        = "private-subnet-${count.index + 1}"
    Terraform   = "true"
    Environment = "rsschool"
  }
}