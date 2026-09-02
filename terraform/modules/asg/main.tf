resource "aws_launch_template" "app" {
  name_prefix   = "safeshare-"
  image_id      = "ami-0e86e20dae9224db8"
  instance_type = "t3.micro"

  user_data = base64encode(file("${path.module}/user_data.sh"))

  iam_instance_profile {
    name = var.instance_profile
  }
}

resource "aws_autoscaling_group" "main" {
  desired_capacity    = 3
  min_size            = 3
  max_size            = 6
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = [var.tg_arn]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}