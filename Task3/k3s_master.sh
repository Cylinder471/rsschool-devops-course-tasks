#!/bin/bash
set -e
echo "Starting user_data script" > /tmp/user_data.log
echo "Hostname: ${hostname}" >> /tmp/user_data.log
echo "Project: ${project}" >> /tmp/user_data.log
echo "AWS Region: ${aws_region}" >> /tmp/user_data.log

sudo hostnamectl set-hostname ${hostname}
echo "Hostname set" >> /tmp/user_data.log

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update && sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
echo "AWS CLI installed" >> /tmp/user_data.log

TOKEN=$(aws ssm get-parameter --name "/edu/${project}/k3s/token" --with-decryption --query "Parameter.Value" --output text --region ${aws_region})
echo "Token is: $TOKEN" >> /tmp/user_data.log

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' K3S_TOKEN="$TOKEN" K3S_KUBECONFIG_MODE='644' sh -s -
echo "K3s installed" >> /tmp/user_data.log
#sleep 30
KUBECONFIG_CONTENT=$(sudo cat /etc/rancher/k3s/k3s.yaml)
aws ssm put-parameter \
  --region ${aws_region} \
  --name "/edu/${project}/k3s/kubeconfig" \
  --value "$KUBECONFIG_CONTENT" \
  --type "SecureString" \
  --overwrite