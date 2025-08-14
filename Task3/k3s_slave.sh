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
sleep 10  # Небольшая пауза после присоединения
#KUBECONFIG_CONTENT=$(aws ssm get-parameter \
#  --name "/edu/${project}/k3s/kubeconfig" \
#  --with-decryption --query "Parameter.Value" \
#  --output text \
#  --region ${aws_region})
#sudo mkdir -p /etc/rancher/k3s
#echo "$KUBECONFIG_CONTENT" | sudo tee /etc/rancher/k3s/k3s.yaml > /dev/null
#sudo chmod 644 /etc/rancher/k3s/k3s.yaml
#echo "Kubeconfig загружен" >> /tmp/user_data.log