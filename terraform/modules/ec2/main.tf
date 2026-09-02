variable "private_subnet_ids" { type = list(string) }
variable "ec2_sg_id" {}
variable "target_group_arn" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --- IAM for SSM ---
resource "aws_iam_role" "ec2_ssm" {
  name = "safeshare-ec2-ssm-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "safeshare-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_launch_template" "main" {
  name_prefix            = "safeshare-flask-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [var.ec2_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y python3-pip
    pip3 install flask requests
    cat > /home/ec2-user/app.py << 'PY'
from flask import Flask, jsonify
import requests
app = Flask(__name__)
def get_meta(path):
    try:
        r = requests.get(f"http://169.254.169.254/latest/meta-data/{path}", timeout=1)
        return r.text
    except:
        return "local"
@app.route("/")
def index():
    return jsonify({"instance_id": get_meta("instance-id"), "az": get_meta("placement/availability-zone"), "health": "healthy"})
@app.route("/health")
def health():
    return jsonify(status="ok"), 200
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PY
    nohup python3 /home/ec2-user/app.py > /var/log/flask.log 2>&1 &
  EOF
  )
}

resource "aws_autoscaling_group" "main" {
  desired_capacity    = 2
  min_size            = 2
  max_size            = 3
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}