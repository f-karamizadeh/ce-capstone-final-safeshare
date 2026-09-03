# variable "private_subnet_ids" { type = list(string) }
# variable "ec2_sg_id" {}
# variable "target_group_arn" {}

# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }
# }

# # --- IAM for SSM ---
# resource "aws_iam_role" "ec2_ssm" {
#   name = "safeshare-ec2-ssm-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = { Service = "ec2.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm" {
#   role       = aws_iam_role.ec2_ssm.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ec2" {
#   name = "safeshare-ec2-profile"
#   role = aws_iam_role.ec2_ssm.name
# }

# resource "aws_launch_template" "main" {
#   name_prefix            = "safeshare-flask-"
#   image_id               = data.aws_ami.amazon_linux.id
#   instance_type          = "t3.micro"
#   key_name = "3tier"
#   vpc_security_group_ids = [var.ec2_sg_id]

#   iam_instance_profile {
#     name = aws_iam_instance_profile.ec2.name
#   }

#     user_data = base64encode(<<-EOF
# #!/bin/bash
# set -x
# dnf update -y
# dnf install -y python3-pip
# pip3 install flask --break-system-packages || pip3 install flask
# mkdir -p /home/ec2-user/uploads
# chmod 777 /home/ec2-user/uploads

# cat > /home/ec2-user/app.py <<'PY'
# from flask import Flask, request, send_from_directory, render_template_string
# import os
# app = Flask(__name__)
# UPLOAD_FOLDER = '/home/ec2-user/uploads'
# os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# HTML = """
# <!doctype html>
# <title>SafeShare - 3Tier</title>
# <h2>SafeShare File Upload / Download</h2>
# <form method=post enctype=multipart/form-data action="/upload">
#   <input type=file name=file>
#   <input type=submit value=Upload>
# </form>
# <hr>
# <h3>Files:</h3>
# <ul>
# {% for f in files %}
#   <li><a href="/download/{{f}}">{{f}}</a> - {{f}}</li>
# {% endfor %}
# </ul>
# <p>Health: <a href="/health">/health</a></p>
# """

# @app.route("/")
# def index():
#     files = os.listdir(UPLOAD_FOLDER)
#     return render_template_string(HTML, files=files)

# @app.route("/health")
# def health():
#     return "ok", 200

# @app.route("/upload", methods=["POST"])
# def upload():
#     f = request.files.get('file')
#     if f and f.filename:
#         f.save(os.path.join(UPLOAD_FOLDER, f.filename))
#     return index()

# @app.route("/download/<name>")
# def download(name):
#     return send_from_directory(UPLOAD_FOLDER, name, as_attachment=True)

# if __name__ == "__main__":
#     app.run(host="0.0.0.0", port=5000)
# PY

# cat > /etc/systemd/system/flask.service <<'SVC'
# [Unit]
# Description=SafeShare Flask
# After=network.target
# [Service]
# User=ec2-user
# WorkingDirectory=/home/ec2-user
# ExecStart=/usr/bin/python3 /home/ec2-user/app.py
# Restart=always
# [Install]
# WantedBy=multi-user.target
# SVC

# systemctl daemon-reload
# systemctl enable flask
# systemctl restart flask
# EOF
#   )
# }

# resource "aws_autoscaling_group" "main" {
#   desired_capacity    = 2
#   min_size            = 2
#   max_size            = 3
#   vpc_zone_identifier = var.private_subnet_ids
#   target_group_arns   = [var.target_group_arn]
#   launch_template {
#     id      = aws_launch_template.main.id
#     version = "$Latest"
#   }
# }

variable "private_subnet_ids" { type = list(string) }
variable "ec2_sg_id" {}
variable "target_group_arn" {}
variable "bucket_name" {
  type = string
  default = "safeshare-files-chemnitz-99"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

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
  role = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "s3_access" {
  name = "safeshare-s3-sync-policy"
  role = aws_iam_role.ec2_ssm.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::${var.bucket_name}"]
      },
      {
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
        Resource = ["arn:aws:s3:::${var.bucket_name}/*"]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "safeshare-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_launch_template" "main" {
  name_prefix = "safeshare-flask-"
  image_id = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  key_name = "3tier"
  vpc_security_group_ids = [var.ec2_sg_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -x
exec > /var/log/user-data.log 2>&1
dnf update -y
dnf install -y python3-pip awscli
pip3 install flask --break-system-packages || pip3 install flask
mkdir -p /home/ec2-user/uploads
chmod 777 /home/ec2-user/uploads
chown ec2-user:ec2-user /home/ec2-user/uploads

cat > /home/ec2-user/app.py <<'PY'
from flask import Flask, request, send_from_directory
import os, socket, urllib.request
app = Flask(__name__)
UPLOAD_FOLDER = '/home/ec2-user/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def get_meta():
    try:
        iid = urllib.request.urlopen("http://169.254.169.254/latest/meta-data/instance-id", timeout=1).read().decode()
        return iid
    except:
        return socket.gethostname()

@app.route("/")
def index():
    files = os.listdir(UPLOAD_FOLDER)
    if files:
        file_list = "".join([f'<li class="file-item"><span class="file-name">📄 {x}</span><a class="btn-small" href="/download/{x}">Download</a></li>' for x in files])
    else:
        file_list = '<p class="empty">No files yet. Upload one!</p>'
    meta = get_meta()
    return f"""<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>SafeShare - 3Tier</title>
<style>
  *{{box-sizing:border-box;font-family:Inter,Segoe UI,sans-serif}}
  body{{background:#0f172a;color:#e2e8f0;margin:0;min-height:100vh;display:flex;justify-content:center;padding:40px 15px}}
 .card{{background:#1e293b;width:100%;max-width:720px;border-radius:20px;padding:28px;box-shadow:0 20px 40px rgba(0,0,0,.4);border:1px solid #334155}}
  h2{{margin:0 0 6px;font-size:26px}}.subtitle{{color:#94a3b8;font-size:13px;margin-bottom:20px}}
 .upload-box{{border:2px dashed #475569;border-radius:12px;padding:24px;text-align:center;background:#0f172a;margin:20px 0}}
  input[type=file]{{color:#cbd5e1}}.btn{{background:#3b82f6;color:white;border:none;padding:10px 20px;border-radius:8px;cursor:pointer;font-weight:600;margin-top:12px}}
 .btn:hover{{background:#2563eb}}.btn-small{{background:#334155;color:#e2e8f0;padding:5px 12px;border-radius:6px;text-decoration:none;font-size:12px}}
 .btn-small:hover{{background:#475569}} ul{{list-style:none;padding:0;margin:0}}.file-item{{display:flex;justify-content:space-between;align-items:center;background:#0f172a;padding:10px 14px;border-radius:8px;margin-bottom:8px;border:1px solid #1e293b}}
 .empty{{color:#64748b;text-align:center}}.footer{{margin-top:20px;font-size:12px;color:#64748b;display:flex;justify-content:space-between}}
 .badge{{background:#10b98120;color:#10b981;padding:3px 8px;border-radius:20px;font-size:11px;border:1px solid #10b98140}}
</style></head>
<body><div class="card">
<h2>🚀 SafeShare <span class="badge">{meta}</span></h2>
<div class="subtitle">3Tier Architecture | Bucket: safeshare-files-chemnitz-99 | Synced via crontab every 1min</div>
<div class="upload-box">
<form method=post enctype=multipart/form-data action="/upload">
<input type=file name=file required><br><button class="btn" type=submit>Upload to S3</button>
</form></div>
<h3>📁 Files ({len(files)})</h3><ul>{file_list}</ul>
<div class="footer"><span>Instance: {meta}</span><a href="/health" style="color:#38bdf8">/health</a></div>
</div></body></html>"""

@app.route("/health")
def health():
    return f"ok - {get_meta()}", 200

@app.route("/upload", methods=["POST"])
def upload():
    f = request.files.get('file')
    if f and f.filename:
        f.save(os.path.join(UPLOAD_FOLDER, f.filename))
    return index()

@app.route("/download/<name>")
def download(name):
    return send_from_directory(UPLOAD_FOLDER, name, as_attachment=True)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PY

chown ec2-user:ec2-user /home/ec2-user/app.py

cat > /etc/systemd/system/flask.service <<'SVC'
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

cat > /usr/local/bin/sync-to-s3.sh <<'EOS'
#!/bin/bash
BUCKET="safeshare-files-chemnitz-99"
DIR="/home/ec2-user/uploads"
LOG="/var/log/s3-sync.log"
echo "--- $(date) ---" >> $LOG
/usr/bin/aws s3 sync $DIR s3://$BUCKET/ --delete >> $LOG 2>&1
/usr/bin/aws s3 sync s3://$BUCKET/ $DIR >> $LOG 2>&1
chmod -R 777 $DIR 2>> $LOG
chown -R ec2-user:ec2-user $DIR 2>> $LOG
EOS

chmod +x /usr/local/bin/sync-to-s3.sh
(crontab -l 2>/dev/null; echo "* * * * * /usr/local/bin/sync-to-s3.sh") | crontab -
/usr/local/bin/sync-to-s3.sh &

EOF
  )
}

resource "aws_autoscaling_group" "main" {
  desired_capacity = 2
  min_size = 2
  max_size = 3
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns = [var.target_group_arn]
  launch_template {
    id = aws_launch_template.main.id
    version = "$Latest"
  }
}