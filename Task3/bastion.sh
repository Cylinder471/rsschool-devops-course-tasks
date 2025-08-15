#!/bin/bash
set -e
sleep 200
sudo hostnamectl set-hostname ${hostname}

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt update && sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir -p /home/ubuntu/.kube
ATTEMPTS=0
MAX_ATTEMPTS=30  # ~5 минут при паузе 10с
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    KUBECONFIG_CONTENT=$(aws ssm get-parameter --name "/edu/${project}/k3s/kubeconfig" --with-decryption --query "Parameter.Value" --output text --region ${aws_region})
    echo "$KUBECONFIG_CONTENT" | sudo tee /home/ubuntu/.kube/config > /dev/null
    if test -f /home/ubuntu/.kube/config && sudo grep -q "clusters:" /home/ubuntu/.kube/config; then
        echo "Kubeconfig готов после $ATTEMPTS попыток" >> /tmp/user_data.log
        break
    fi
    echo "Ожидание kubeconfig... Попытка $ATTEMPTS" >> /tmp/user_data.log
    sleep 10
    ATTEMPTS=$((ATTEMPTS+1))
done
rm kubectl
sudo sed -i "s|server: https://127.0.0.1:6443|server: https://${master_ip}:6443|" /home/ubuntu/.kube/config
sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
echo "export KUBECONFIG=/home/ubuntu/.kube/config" >> /home/ubuntu/.bashrc
sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc