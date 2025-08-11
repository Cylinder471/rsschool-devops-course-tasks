terraform {
  backend "s3" {
    bucket = "cylinder-terraform-remote-state"
    key    = "rsschool/task2/terrafor.tfstate"
    region = "us-east-1"
  }
}