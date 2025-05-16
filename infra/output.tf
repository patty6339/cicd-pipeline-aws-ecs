
# Output the name servers for the Route53 hosted zone
output "route53_name_servers" {
  value = aws_route53_zone.hosted_zone.name_servers
  
}
