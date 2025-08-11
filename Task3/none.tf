#resource "null_resource" "download_kubeconfig" {
#  depends_on = [null_resource.copy_kubeconfig_to_ssm]
#
#  provisioner "local-exec" {
#    command = "aws ssm get-parameter --name '/edu/${var.project_name}/k3s/kubeconfig' --with-decryption --query 'Parameter.Value' --output text --region ${var.aws_region} > ~/k3s.yaml"
#  }
#}