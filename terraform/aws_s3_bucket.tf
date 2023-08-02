variable "domain_name" {
    default = "devops-cdn.orbitspot.com"
}

resource "aws_s3_bucket" "default" {
    bucket = var.domain_name
}

resource "aws_s3_bucket_cors_configuration" "default" {
    bucket = aws_s3_bucket.default.id

    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "HEAD"]
        allowed_origins = ["*"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
    }
}

resource "aws_s3_bucket_acl" "default" {
    bucket = aws_s3_bucket.default.id
    acl    = "public-read"
    depends_on = [aws_s3_bucket_ownership_controls.default]
}

resource "aws_s3_bucket_ownership_controls" "default" {
    bucket = aws_s3_bucket.default.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
    depends_on = [aws_s3_bucket_public_access_block.default]
}

resource "aws_s3_bucket_public_access_block" "default" {
    bucket = aws_s3_bucket.default.id

    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "default" {
    bucket = aws_s3_bucket.default.id
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Principal = "*"
                Action = [
                    "s3:*",
                ]
                Effect = "Allow"
                Resource = [
                    "arn:aws:s3:::devops-cdn.orbitspot.com",
                    "arn:aws:s3:::devops-cdn.orbitspot.com/*"
                ]
            },
            {
                Sid = "PublicReadGetObject"
                Principal = "*"
                Action = [
                    "s3:GetObject",
                ]
                Effect   = "Allow"
                Resource = [
                    "arn:aws:s3:::devops-cdn.orbitspot.com",
                    "arn:aws:s3:::devops-cdn.orbitspot.com/*"
                ]
            },
        ]
    })

    depends_on = [aws_s3_bucket_public_access_block.default]
}

resource "aws_s3_object" "default" {
    for_each = fileset("./dist/fuse/", "*")
    bucket = aws_s3_bucket.default.id
    key    = "front-1/${each.value}"
    acl    = "public-read"
    source = "./dist/fuse/${each.value}"
    etag   = filemd5("./dist/fuse/${each.value}")
}

