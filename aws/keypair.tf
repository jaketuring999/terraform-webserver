resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.key_pair.public_key_openssh
}

output "private_key" {
  value = tls_private_key.key_pair.private_key_pem
  sensitive = true
}
