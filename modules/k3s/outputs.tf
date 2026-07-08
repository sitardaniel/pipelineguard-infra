output "instance_id" {
  description = "EC2 instance ID of the k3s node"
  value       = aws_instance.node.id
}

output "public_ip" {
  description = "Public IP of the k3s node"
  value       = aws_instance.node.public_ip
}

output "node_security_group_id" {
  description = "Security group ID for the k3s node"
  value       = aws_security_group.node.id
}
