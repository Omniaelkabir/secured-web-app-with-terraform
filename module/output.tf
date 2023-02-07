
output "public_subnet_id1"{
 value = aws_subnet.public1.id   
}
output "public_subnet_id2"{
 value = aws_subnet.public2.id   
}
output "private_subnet_id1"{
 value = aws_subnet.private1.id   
}
output "private_subnet_id2"{
 value = aws_subnet.private2.id   
}
output "secgroup-id" {
value = aws_security_group.secgroup.id    
}
output "pivatedns" {
  value = aws_lb.private-lb.dns_name
}