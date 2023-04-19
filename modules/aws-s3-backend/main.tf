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