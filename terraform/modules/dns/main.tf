resource "aws_route53_zone" "private" {
  name = "${var.project_name}.internal"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.project_name}-private-zone"
  }
}

# DB Record
resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db.${var.project_name}.internal"
  type    = "CNAME"
  ttl     = "300"
  records = [var.db_endpoint]
}

# App Record (ALB)
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "app.${var.project_name}.internal"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
