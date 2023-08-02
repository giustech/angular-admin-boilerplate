output "website_endpoint" {
    value = aws_s3_bucket.default
}

output "bucket_regional_domain_name" {
    value = aws_s3_bucket.default.bucket_regional_domain_name
}
