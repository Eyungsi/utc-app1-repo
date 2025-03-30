output "aws_instance_id" {
  value = aws_instance.utc-app1.public_ip
}
output "public_ip" {
  value = aws_subnet.utc-public-sub1.map_public_ip_on_launch
}
output "key_name" {
  value = aws_key_pair.utc-key.key_name
}
output "aws_eip" {
  value = aws_eip.utc-eip.public_ip
}
output "aws_volume_attachment" {
  value = aws_ebs_volume.utc-ebs.size
}
output "aws_route53_record" {
  value = aws_route53_record.utc-dns.name
}
