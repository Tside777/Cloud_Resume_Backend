resource "aws_s3_bucket" "backend_bucket" {
    bucket = "trevors-cloud-resume-backend-bucket"
    tags = {
        Name = "Backend Bucket"
        Environment = "Prod"
    }
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.backend_bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_acl" "backend_acl" {
    bucket = aws_s3_bucket.backend_bucket.id
    acl = "private"
}

resource "aws_s3_bucket_public_access_block" "backend_bucket_public_acces" {
  bucket = aws_s3_bucket.backend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}