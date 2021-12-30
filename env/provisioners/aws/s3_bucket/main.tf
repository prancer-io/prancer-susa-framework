module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = var.bucket_name
  acl    = var.acl

  versioning = {
    enabled = var.versioning_enabled
  }

}
