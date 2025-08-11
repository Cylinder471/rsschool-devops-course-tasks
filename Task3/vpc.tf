resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "my-vpc"
    Terraform   = "true"
    Environment = "rsschool/task2"
  }
}
resource "aws_eip" "nat" {
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}
