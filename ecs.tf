# ECS Cluster.
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

# Load Balancer for ECS Cluster.
resource "aws_alb" "ecs_cluster" {
  name = "ecs-cluster"
  #  Allow ingress to Load Balancer, and allow it to talk to all node in the VPC.
  security_groups = [
    "${aws_security_group.alb_sg.id}",
    "${aws_security_group.intra_node_communication.id}",
  ]
  subnets = aws_subnet.public_subnet.*.id
}

# Target group for the ECS cluster nodes for ALB.
resource "aws_alb_target_group" "ecs_nodes_tg" {
  name                 = "ECS-Nodes-TG"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = aws_vpc.ecs_cluster.id
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200-299"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_alb.ecs_cluster"]
}

#  Listener, which forwards traffic to the Target Group.
resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.ecs_cluster.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs_nodes_tg.arn
    type             = "forward"
  }
}

#  Attach the Target Group to the Cluster Nodes Auto-Scaling Group.
resource "aws_autoscaling_attachment" "ecs-nodes-scaling-attachment" {
  autoscaling_group_name = aws_autoscaling_group.ecs_cluster_node.id
  alb_target_group_arn   = aws_alb_target_group.ecs_nodes_tg.arn
}
