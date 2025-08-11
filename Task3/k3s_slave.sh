#!/bin/bash
set -e

sudo hostnamectl set-hostname ${hostname}

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update && sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install

sleep 60 
K3S_TOKEN=$(aws ssm get-parameter \
   --name "/edu/${project}/k3s/token" \
   --with-decryption --query "Parameter.Value" \
   --output text \
   --region ${aws_region})




curl -sfL https://get.k3s.io | K3S_URL=https://${master_ip}:6443 K3S_TOKEN=$K3S_TOKEN sh -