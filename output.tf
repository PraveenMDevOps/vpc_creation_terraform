output "jumphost_public_ip" {
  value = aws_instance.jumphost.public_ip
}

output "jumphost_private_ip" {
  value = aws_instance.jumphost.private_ip
}

output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "frontend_private_ip" {
  value = aws_instance.frontend.private_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}
