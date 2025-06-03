#!/bin/bash

sudo yum install -y amazon-cloudwatch-agent
sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOT
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "EC2-System-Logs",
            "log_stream_name": "i-0b8398f496ca71426"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "EC2-CloudInit-Logs",
            "log_stream_name": "i-0b8398f496ca71426"
          }
        ]
      }
    }
  }
}
EOT

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s
sudo yum update -y

sudo amazon-linux-extras enable nginx1
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<html><h1>Welcome from Nginx on Amazon Linux 2</h1></html>" | \
  sudo tee /usr/share/nginx/html/index.html > /dev/null

sudo systemctl restart nginx
