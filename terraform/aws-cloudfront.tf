resource "aws_cloudfront_origin_access_control" "default" {
    name                              = "CloudFront S3 OAC"
    description                       = "Cloud Front S3 OAC"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "default" {
    enabled = false
    origin {
        domain_name = aws_s3_bucket.default.bucket_regional_domain_name
        origin_id   = aws_s3_bucket.default.bucket
        origin_access_control_id = aws_cloudfront_origin_access_control.default.id
        origin_path = "front-1"
    }
    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD"]
        cached_methods   = ["GET", "HEAD"]
        target_origin_id = "distribution"

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "allow-all"
        min_ttl                = 0
        default_ttl            = 3600
        max_ttl                = 86400
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
    restrictions {
        geo_restriction {
            restriction_type = "none"
            locations        = []
        }
    }
#    default_cache_behavior {
#        allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#        cached_methods   = ["GET", "HEAD", "OPTIONS"]
#        target_origin_id = aws_s3_bucket.default.bucket
#        forwarded_values {
#            query_string = false
#            cookies {
#                forward = "none"
#            }
#        }
#        viewer_protocol_policy = "redirect-to-https"
#    }
#    restrictions {
#        geo_restriction {
#            restriction_type = "whitelist"
#            locations        = ["US", "BR"]
#        }
#    }
#    viewer_certificate {
#
#    }

}
