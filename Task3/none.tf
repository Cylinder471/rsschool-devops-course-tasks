# Null resource для настройки kubeconfig и туннеля
resource "null_resource" "setup_local_kubeconfig" {
  depends_on = [
    aws_instance.bastion_host_ec2_instance]

  provisioner "local-exec" {
    command = <<EOT
      echo "Ожидаем kubeconfig в SSM и скачиваем его..."
      mkdir -p ~/.kube
      ATTEMPTS=0
      MAX_ATTEMPTS=30  # ~5 минут при паузе 10с
      while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
          aws ssm get-parameter \
          --name "/edu/${var.project_name}/k3s/kubeconfig" \
          --with-decryption --query "Parameter.Value" \
          --output text \
          --region "${var.aws_region}" > ~/.kube/config-k3s
          if test -f ~/.kube/config-k3s && grep -q "clusters:" ~/.kube/config-k3s; then
              echo "Kubeconfig готов после $ATTEMPTS попыток" >> /tmp/user_data.log
              break
          fi
          echo "Ожидание kubeconfig... Попытка $ATTEMPTS" >> /tmp/user_data.log
          sleep 10
          ATTEMPTS=$((ATTEMPTS+1))
      done
      echo "${aws_instance.in_private1.private_ip}" > ~/.kube/k3s-master-ip.txt
      echo 'export KUBECONFIG=$HOME/.kube/config-k3s' >> ~/.bashrc
      echo "Ожидаем доступность SSH бастиона..."
      for i in {1..20}; do
        if nc -z ${aws_instance.bastion_host_ec2_instance.public_ip} 22; then
          echo "Bastion доступен по SSH"
          break
        fi
        echo "Ожидание SSH..."
        sleep 10
      done

      echo "Запускаем SSH-туннель..."
      ssh -i ${var.ssh_key_path} \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -L 6443:${aws_instance.in_private1.private_ip}:6443 \
        ubuntu@${aws_instance.bastion_host_ec2_instance.public_ip} \
        -N -f \
        -o "ServerAliveInterval 30" \
        -o "ServerAliveCountMax 3"

      echo "✅ Kubeconfig сохранён в ~/.kube/config-k3s. SSH-туннель запущен."
    EOT
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion_host_ec2_instance.public_ip  # Замени на свой инстанс bastion
}
