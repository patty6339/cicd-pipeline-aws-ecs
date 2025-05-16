# Request public certificates from the Amazon Certificate Manager (ACM)
# This creates a new SSL/TLS certificate for the specified domain and its subdomains
resource "aws_acm_certificate" "acm_certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  # Ensure new certificate is created before destroying the old one
  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS records in Route 53 for domain validation
# This adds the required CNAME records that ACM uses to validate domain ownership
resource "aws_route53_record" "route53_record" {
  # Iterate through all domain validation options provided by ACM
  for_each = {
    for dvo in aws_acm_certificate.acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60 # Time-to-live in seconds
  type            = each.value.type
  zone_id         = aws_route53_zone.hosted_zone.id
}

# Validate ACM certificates by waiting for DNS validation to complete
# This ensures the certificate is fully validated before it can be used
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}
