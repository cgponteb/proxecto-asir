output "private_zone_id" {
  value = aws_route53_zone.private.zone_id
}

output "db_record" {
  value = aws_route53_record.db.fqdn
}
