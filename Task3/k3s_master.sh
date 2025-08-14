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
aws ssm delete-parameter \
  --region ${aws_region} \
  --name "/edu/${project}/k3s/kubeconfig" || true
TOKEN=$(aws ssm get-parameter --name "/edu/${project}/k3s/token" --with-decryption --query "Parameter.Value" --output text --region ${aws_region})
echo "Token is: $TOKEN" >> /tmp/user_data.log

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC='server' K3S_TOKEN="$TOKEN" K3S_KUBECONFIG_MODE='644' sh -s -
echo "K3s installed" >> /tmp/user_data.log
# Ожидание готовности kubeconfig
ATTEMPTS=0
MAX_ATTEMPTS=30  # ~5 минут при паузе 10с
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if sudo test -f /etc/rancher/k3s/k3s.yaml && sudo grep -q "clusters:" /etc/rancher/k3s/k3s.yaml; then
        echo "Kubeconfig готов после $ATTEMPTS попыток" >> /tmp/user_data.log
        break
    fi
    echo "Ожидание kubeconfig... Попытка $ATTEMPTS" >> /tmp/user_data.log
    sleep 10
    ATTEMPTS=$((ATTEMPTS+1))
done

if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    echo "Таймаут ожидания kubeconfig" >> /tmp/user_data.log
    exit 1  # Ошибка, если файл не готов
fi
KUBECONFIG_CONTENT=$(sudo cat /etc/rancher/k3s/k3s.yaml)
aws ssm put-parameter \
  --region ${aws_region} \
  --name "/edu/${project}/k3s/kubeconfig" \
  --value "$KUBECONFIG_CONTENT" \
  --type "SecureString" \
  --overwrite
echo "Kubeconfig загружен" >> /tmp/user_data.log