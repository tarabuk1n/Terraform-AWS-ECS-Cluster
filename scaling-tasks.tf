# CloudWatch Alarm that monitors CPU Utilization of containers for Scaling Up.

resource "aws_cloudwatch_metric_alarm" "appserver_cpu_high" {
  alarm_name = "appserver-cpu-utilization-above"
  alarm_description = "This alarm monitors appserver CPU utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name         = "CPUUtilization"
  namespace = "AWS/ECS"
  evaluation_periods = "1"
  period = "60"
  statistic = "Average"
  threshold = "3"
  alarm_actions = ["${aws_appautoscaling_policy.app_scale_up.arn}"]

  dimensions = {
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.ecs-service.name}"
  }
}

# CloudWatch Alarm that monitors CPU Utilization of containers for Scaling Down.
resource "aws_cloudwatch_metric_alarm" "appserver_cpu_low" {
  alarm_name = "appserver-cpu-utilization-below"
  alarm_description = "This alarm monitors appserver memory utilization for scaling down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = "1"
  alarm_actions = ["${aws_appautoscaling_policy.app_scale_down.arn}"]

  dimensions ={
    ClusterName = "${aws_ecs_cluster.ecs_cluster.name}"
    ServiceName = "${aws_ecs_service.ecs-service.name}"
  }
}

resource "aws_appautoscaling_target" "target" {
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs-service.name}"
  role_arn = "${aws_iam_role.ecs-service-role.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  min_capacity = "${var.app_min_capacity}"
  max_capacity = "${var.app_max_capacity}"
}


resource "aws_appautoscaling_policy" "app_scale_up" {
  name = "appserver-scale-up"
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_appautoscaling_policy" "app_scale_down" {
  name = "appserver-scale-down"
  resource_id = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = ["aws_appautoscaling_target.target"]
}

# EC2 Scale Up Alarm
resource "aws_autoscaling_policy" "ec2-cpu-policy" {
  name                   = "ec2-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.ecs_cluster_node.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "60"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "ec2-cpu-alarm" {
  alarm_name          = "ec2-cpu-alarm"
  alarm_description   = "ec2-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "2"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs_cluster_node.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.ec2-cpu-policy.arn]
}

# EC2 Scale Down Alarm
resource "aws_autoscaling_policy" "ec2-cpu-policy-scaledown" {
  name                   = "ec2-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.ecs_cluster_node.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "60"
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "ec2-cpu-alarm-scaledown" {
  alarm_name          = "ec2-cpu-alarm-scaledown"
  alarm_description   = "ec2-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs_cluster_node.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.ec2-cpu-policy-scaledown.arn]
}