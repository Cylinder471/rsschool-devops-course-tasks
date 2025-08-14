data "aws_ssm_parameter" "k3s_kubeconfig" {
  name            = "/edu/${var.project_name}/k3s/kubeconfig"
  with_decryption = true
}

# Null resource для настройки kubeconfig и туннеля
resource "null_resource" "setup_local_kubeconfig" {
  depends_on = [
    aws_instance.bastion_host_ec2_instance,
    data.aws_ssm_parameter.k3s_kubeconfig
  ]

  provisioner "local-exec" {
    command = <<EOT
      echo "Ожидаем kubeconfig в SSM..."
      for i in {1..30}; do
        if aws ssm get-parameter \
          --name "/edu/${var.project_name}/k3s/kubeconfig" \
          --with-decryption \
          --region ${var.aws_region}; then
          echo "Kubeconfig найден"
          break
        fi
        echo "Параметр не найден, ждем..."
        sleep 10
      done

      mkdir -p ~/.kube

      echo "Скачиваем kubeconfig..."
      aws ssm get-parameter \
        --name "/edu/${var.project_name}/k3s/kubeconfig" \
        --with-decryption \
        --query "Parameter.Value" \
        --output text \
        --region ${var.aws_region} > ~/.kube/config-k3s

      echo "${aws_instance.in_private1.private_ip}" > ~/.kube/k3s-master-ip.txt

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
