#!/bin/bash
yum update -y
yum install -y python3 pip amazon-cloudwatch-agent ansible git
pip3 install flask boto3 requests

mkdir -p /opt/safeshare
aws s3 cp s3://safeshare-files-chemnitz-99/app/ /opt/safeshare/ --recursive || true

cat <<'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/config.json
{
  "metrics": {
    "metrics_collected": {
      "mem": { "measurement": ["mem_used_percent"] },
      "cpu": { "measurement": ["cpu_usage_idle"] }
    }
  }
}
EOF

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json -s

nohup python3 /opt/safeshare/app.py > /var/log/app.log 2>&1 &