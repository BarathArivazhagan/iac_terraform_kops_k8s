resource "aws_route53_record" "k8s_api_server_record" {
  zone_id = var.route53_zone_id
  name    = var.api_server_route_name
  type    = "A"
  alias {
    name                   =  var.alb_name
    zone_id                =  var.alb_zone_id
    evaluate_target_health = false
  }
}
