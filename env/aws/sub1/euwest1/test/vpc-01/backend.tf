terraform {
  backend "s3" {
    bucket = "tfstate-by-maxo"
    key    = "aws/sub1/euwest1/test/vpc-01//terraform.tfstate"
    region = "eu-west-1"
  }
}
