# SSH keypair to access instances.
resource "aws_key_pair" "keypair" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# A Launch Configuration for ECS cluster instances.
resource "aws_launch_configuration" "ecs_cluster_node" {

  name_prefix          = "ecs-cluster-node-"
  image_id             = data.aws_ami.latest_ecs.id
  instance_type        = var.instance_size
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.id

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    "${aws_security_group.intra_node_communication.id}",
    "${aws_security_group.instance_sg.id}",
    "${aws_security_group.ssh_access.id}"
  ]
  associate_public_ip_address = "true"
  key_name                    = aws_key_pair.keypair.key_name
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}' > /etc/ecs/ecs.config"
}

resource "aws_autoscaling_group" "ecs_cluster_node" {
  name                 = "ecs_cluster_node"
  min_size             = var.node_min
  max_size             = var.node_count
  desired_capacity     = var.node_desired
  vpc_zone_identifier  = aws_subnet.private_subnet.*.id
  launch_configuration = aws_launch_configuration.ecs_cluster_node.name
  health_check_type    = "ELB"

  warm_pool {
    pool_state                  = "Stopped"
    min_size                    = var.pool_min_capacity
    max_group_prepared_capacity = var.pool_max_capacity
      instance_reuse_policy {
      reuse_on_scale_in = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ECS Cluster Instance"
    propagate_at_launch = true
  }

}
