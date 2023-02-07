output "publicec-id1" {
  value = aws_instance.public-ec1.id
}
output "publicec-id2" {
  value = aws_instance.public-ec2.id
}
output "privateec-id1" {
  value = aws_instance.private-ec1.id
}
output "privateec-id2" {
  value = aws_instance.private-ec2.id
}