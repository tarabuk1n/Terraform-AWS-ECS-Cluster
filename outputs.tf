output "endpoint" {
  value = "http://${aws_alb.ecs_cluster.dns_name}"
}
