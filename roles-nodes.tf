#  Policy for the ECS Instances.
data "aws_iam_policy_document" "ec2-instance-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#  Role for the ECS Instances, with the policy document.
resource "aws_iam_role" "cluster-instance-role" {
  name                = "ecs-instance-role"
  path                = "/"
  assume_role_policy  = "${data.aws_iam_policy_document.ec2-instance-policy.json}"
}

#  Attaches the ECS Service to the EC2 Role (for it to make required ECS API calls).
resource "aws_iam_role_policy_attachment" "ecs-instance-role-attachment" {
  role       = "${aws_iam_role.cluster-instance-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#  Instance profile for the ECS instances.
resource "aws_iam_instance_profile" "ecs-instance-profile" {
  name = "ecs-instance-profile"
  path = "/"
  role = "${aws_iam_role.cluster-instance-role.id}"

  # Give a little extra time, as roles can take a while to create.
  provisioner "local-exec" {
    command = "sleep 10"
  }
}