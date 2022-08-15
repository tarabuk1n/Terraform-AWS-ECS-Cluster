# Security Group for the Cluster Load Balancer.
resource "aws_security_group" "alb_sg" {
  name        = "sg_to_internet"
  description = "Allow incoming HTTP"
  vpc_id      = "${aws_vpc.ecs_cluster.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This Security Group Allows Traffic to the instances for HTTP.
resource "aws_security_group" "instance_sg" {
  name        = "sg_to_alb"
  description = "Security group that allows traffic(only) from ALB"
  vpc_id      = "${aws_vpc.ecs_cluster.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.alb_sg.id}"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}-cluster-public-ingress-${var.environment}"
  }
}

# This Security Group Allows Intra-Node Communication on All Ports with All Protocols.
resource "aws_security_group" "intra_node_communication" {
  name        = "intra_node"
  description = "SG that allows all instances in the VPC to talk to each other."
  vpc_id      = "${aws_vpc.ecs_cluster.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  tags = {
    Name = "${var.name}-cluster-intra-node-connect-${var.environment}"
  }
}

resource "aws_security_group" "ecs_app_sg" {
  name        = "ecs-app-sg"
  description = "Allow inbound access from the Web only"
  vpc_id      = "${aws_vpc.ecs_cluster.id}"

  ingress {
      protocol        = "tcp"
      from_port       = 80
      to_port         = 80
      cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}-ecs-app-sg-${var.environment}"
  }
}

resource "aws_security_group" "ssh_access" {
  name        = "ssh_access"
  description = "Security group that allows public access over SSH."
  vpc_id      = "${aws_vpc.ecs_cluster.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-SSH-Access-${var.environment}"
  }
}

