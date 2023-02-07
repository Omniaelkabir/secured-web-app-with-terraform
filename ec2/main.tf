resource "aws_instance" "public-ec1" {
 ami           = var.ami_id
 instance_type = var.type
 associate_public_ip_address = true
 subnet_id = var.publics1-id
 vpc_security_group_ids = [var.securitygroupid]
 key_name = "My_key"
 tags = {
    Name = "public-ec1"
  }
 provisioner "local-exec" {
  when = create
   command = "echo public_ip1  ${self.public_ip} >> ./Public_IPs.txt"
 }
 provisioner "remote-exec" {
    inline = var.provisionerdata
     connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("./ec2/My_key.pem")
      host = self.public_ip
    }
  }
}

resource "aws_instance" "public-ec2" {
 ami           = var.ami_id
  instance_type = var.type
  associate_public_ip_address = true
  subnet_id = var.publics2-id
  vpc_security_group_ids = [var.securitygroupid]
  key_name = "My_key"
  tags = {
    Name = "public-ec2"
  }
  provisioner "local-exec" {
    when = create
   command = "echo public_ip2  ${self.public_ip} >> ./Public_IPs.txt"
 }
 connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("./ec2/My_key.pem")
      host = self.public_ip
    }

 provisioner "remote-exec" {
    inline =         var.provisionerdata 
  }
}

resource "aws_instance" "private-ec1" {
 ami           = var.ami_id
  instance_type = var.type
  associate_public_ip_address = false
  subnet_id = var.privates1-id
  vpc_security_group_ids = [var.securitygroupid]
  tags = {
    Name = "private-ec1"
  }
  
  user_data = file("ec2/install-apache.sh")

}

resource "aws_instance" "private-ec2" {
 ami           = var.ami_id
  instance_type = var.type
  associate_public_ip_address = false
  subnet_id = var.privates2-id
  vpc_security_group_ids = [var.securitygroupid]
  tags = {
    Name = "private-ec2"
  }
  
  user_data = file("ec2/install-apache.sh")
}