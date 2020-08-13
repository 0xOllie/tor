output "servers" {
  value = [aws_instance.default.*.public_ip]
}