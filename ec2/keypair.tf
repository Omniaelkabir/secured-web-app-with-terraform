resource "tls_private_key" "terraform_private_key" {
    algorithm = "RSA"
    rsa_bits = 4096
  
}

resource "aws_key_pair" "key" {
    key_name = "My_key"
    public_key = tls_private_key.terraform_private_key.public_key_openssh
    provisioner "local-exec" {
        
        command = <<-EOT
        echo '${tls_private_key.terraform_private_key.private_key_pem}' > My_key.pem
        chmod 400 My_key.pem
        EOT
    
    }

}