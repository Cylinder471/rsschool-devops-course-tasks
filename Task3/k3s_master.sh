#!/bin/bash
set -e
sudo hostnamectl set-hostname ${hostname}
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update && sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
TOKEN=$(aws ssm get-parameter --name "/edu/${project}/k3s/token" --with-decryption --query "Parameter.Value" --output text --region ${aws_region})

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' K3S_TOKEN="$TOKEN" K3S_KUBECONFIG_MODE='644' sh -s -

KUBECONFIG_CONTENT=$(sudo cat /etc/rancher/k3s/k3s.yaml)
aws ssm put-parameter \
  --region ${aws_region} \
  --name "/edu/${project}/k3s/kubeconfig" \
  --value "$KUBECONFIG_CONTENT" \
  --type "SecureString" \
  --overwrite
echo "Kubeconfig загружен" >> /tmp/user_data.log