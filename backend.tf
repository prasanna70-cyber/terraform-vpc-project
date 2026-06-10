terraform {

  backend "s3" {

    bucket = "terraform-20309"

    key = "project1/terraform.tfstate"

    region = "ap-south-1"
  }
}

