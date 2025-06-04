# Create Hosted Zone In Route 53
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}


## Create  Route 53 records
resource "aws_route53_record" "websiteurl" {
  name    = var.domain_name
  zone_id = aws_route53_zone.hosted_zone.id
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
  depends_on = [
    aws_lb.alb
  ]

}