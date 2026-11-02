
# This block requests an SSL certificate for all first-level subdomains of your domain.
resource "aws_acm_certificate" "ecs_domain_certificate" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.domain_name}-certificate"
  }
}

#Find the existing public DNS zone for your domain so Terraform knows where to add the certificate validation record.
data "aws_route53_zone" "ecs_domain_zone" { 
  name = var.domain_name
  private_zone = false
}

# Create a DNS record to validate the ACM certificate.
/*
resource "aws_route53_record" "ecs_cert_validation_records" {
  zone_id = data.aws_route53_zone.ecs_domain_zone.zone_id
  name    = "${aws_acm_certificate.ecs_domain_certificate.domain_validation_options[0].resource_record_name}"
  type    = "${aws_acm_certificate.ecs_domain_certificate.domain_validation_options[0].resource_record_type}"
  records = ["${aws_acm_certificate.ecs_domain_certificate.domain_validation_options[0].resource_record_value}"]
  ttl     = 60

  allow_overwrite = true
}
*/
resource "aws_route53_record" "ecs_cert_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.ecs_domain_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.ecs_domain_zone.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# Validate the ACM certificate using the DNS record created above.
resource "aws_acm_certificate_validation" "ecs_domain_certificate_validation" {
  certificate_arn         = aws_acm_certificate.ecs_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.ecs_cert_validation_records : record.fqdn]
}
/**
Terraform block	                        Purpose
aws_acm_certificate	                    Requests the SSL/TLS certificate
aws_route53_zone data source	        Finds the existing public hosted zone
aws_route53_record	                    Creates the DNS validation record
aws_acm_certificate_validation	        Waits for ACM to validate and issue the certificate

Remember this sequence for interviews:
Request Certificate → Find Hosted Zone → Create DNS Record → Validate Certificate → Use HTTPS.
**/