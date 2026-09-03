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
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
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
  key_name = "3tier"
  vpc_security_group_ids = [var.ec2_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -x
    dnf update -y
    dnf install -y python3-pip
    pip3 install flask werkzeug --break-system-packages || pip3 install flask

    mkdir -p /home/ec2-user/uploads
    chmod 777 /home/ec2-user/uploads

    cat > /home/ec2-user/app.py << 'PY'
from flask import Flask, request, send_from_directory, render_template_string
import os

app = Flask(__name__)
UPLOAD_FOLDER = '/home/ec2-user/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

HTML = """
<!doctype html>
<title>SafeShare - 3Tier</title>
<h2>SafeShare File Upload / Download</h2>
<form method=post enctype=multipart/form-data action="/upload">
  <input type=file name=file>
  <input type=submit value=Upload>
</form>
<hr>
<h3>Files:</h3>
<ul>
{% for f in files %}
  <li><a href="/download/{{f}}">{{f}}</a></li>
{% endfor %}
</ul>
<p>Health: <a href="/health">/health</a></p>
"""

@app.route("/")
def index():
    files = os.listdir(UPLOAD_FOLDER)
    return render_template_string(HTML, files=files)

@app.route("/health")
def health():
    return "ok", 200

@app.route("/upload", methods=["POST"])
def upload():
    f = request.files.get('file')
    if f:
        f.save(os.path.join(UPLOAD_FOLDER, f.filename))
    return index()

@app.route("/download/<name>")
def download(name):
    return send_from_directory(UPLOAD_FOLDER, name, as_attachment=True)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PY

    cat > /etc/systemd/system/flask.service << 'SVC'
[Unit]
Description=SafeShare Flask
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/app.py
Restart=always

[Install]
WantedBy=multi-user.target
SVC

    systemctl daemon-reload
    systemctl enable flask
    systemctl restart flask
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