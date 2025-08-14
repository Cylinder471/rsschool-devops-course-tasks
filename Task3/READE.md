 Data source для SSM
data "aws_ssm_parameter" "k3s_kubeconfig" {
  name            = "/edu/${var.project_name}/k3s/kubeconfig"
  with_decryption = true
}

# Null resource для настройки kubeconfig и туннеля
resource "null_resource" "setup_local_kubeconfig" {
  depends_on = [aws_instance.bastion_host_ec2_instance, data.aws_ssm_parameter.k3s_kubeconfig]  # Замени на свои ресурсы

  provisioner "local-exec" {
    command = <<EOT
      # Скачай kubeconfig из SSM
      aws ssm get-parameter --name "/edu/${var.project_name}/k3s/kubeconfig" --with-decryption --query "Parameter.Value" --output text --region ${var.aws_region} > ~/.kube/config-k3s

      # Запусти SSH-туннель с указанием ключа
ssh -i ${var.ssh_key_path} \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -L 6443:${aws_instance.in_private1.private_ip}:6443 \
  ubuntu@${aws_instance.bastion_host_ec2_instance.public_ip} \
  -N -f \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3"

      echo "Kubeconfig сохранён в ~/.kube/config-k3s. SSH-туннель запущен."
    EOT
  }

  # Остановка туннеля при уничтожении ресурса
provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      # Прочитай private_ip из файла
      MASTER_IP=$(cat ~/.kube/k3s-master-ip.txt || echo "")
      if [ -n "$MASTER_IP" ]; then
        kill $(pgrep -f "ssh -L 6443:$MASTER_IP:6443") || true
        rm -f ~/.kube/k3s-master-ip.txt
      fi
    EOT
  }
}

output "bastion_public_ip" {
  value = aws_instance.bastion_host_ec2_instance.public_ip  # Замени на свой инстанс bastion
}