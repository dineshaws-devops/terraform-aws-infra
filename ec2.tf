data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = <<-EOT
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now nginx
    echo "<h1>Hello from Terraform - Dinesh</h1>" > /usr/share/nginx/html/index.html
  EOT

  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "devops-web-server"
  }
}

output "web_public_ip" {
  value = aws_instance.web.public_ip
}
