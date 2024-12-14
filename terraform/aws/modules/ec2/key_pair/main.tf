resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = tls_private_key.this.public_key_openssh

  tags = {
    Name = var.key_name
  }
}

resource "local_file" "keypair_pem" {
  filename        = "${var.key_name}.pem"
  content         = tls_private_key.this.private_key_pem
  file_permission = "0600" # Change permission.
}
