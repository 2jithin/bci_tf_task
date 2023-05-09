# EC2
resource "aws_instance" "ec2-instance" {

  count                  = var.instance_count
  get_password_data      = var.get_password_data

  ami                    = var.AMIS[var.region]

  instance_type          = var.ec2_type

  # the VPC subnet
  subnet_id              = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name  = aws_key_pair.mykeypair.key_name


  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              useradd admin # Create the admin user
              usermod -aG wheel admin  # Add the admin user to the sudo group
              admin -c 'mkdir ~/.ssh'  # Create the .ssh directory for the admin user
              su admin -c 'chmod 700 ~/.ssh'  # Set permissions for the .ssh directory
              su admin -c 'touch ~/.ssh/authorized_keys'  # Create the authorized_keys file
              su admin -c 'chmod 600 ~/.ssh/authorized_keys'  # Set permissions for the authorized_keys file
              echo "admin:${random_string.admin_passwords[count.index].result}" | chpasswd
              EOF

  lifecycle {
    ignore_changes = [tags]
    create_before_destroy = true
  }

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  tags = {
    Name = "${var.project}_unique_stage_${count.index + 1}"
    Batch = "5AM"
    Terraform   = "true"
    Environment = var.stage
  }

  provisioner "local-exec" {
    #command     = "instance_count=${var.instance_count}; source_ip=${self.private_ip}; target_ip=${element(aws_instance.ec2_instance.*.private_ip, (count.index+1)%var.instance_count)}; ping -c 1 $target_ip >/dev/null 2>&1; if [ $? -eq 0 ]; then echo 'Ping from $source_ip to $target_ip: PASS'; else echo 'Ping from $source_ip to $target_ip: FAIL'; fi"
    command     = "ping -c 1 ${self.private_ip} >/dev/null 2>&1; if [ $? -eq 0 ]; then echo 'Ping from $source_ip to $target_ip: PASS'; else echo 'Ping from $source_ip to $target_ip: FAIL'; fi"
    when        = create
    interpreter = ["/bin/bash", "-c"]
    on_failure  = continue
  }
}
