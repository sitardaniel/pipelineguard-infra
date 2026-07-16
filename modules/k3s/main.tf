# k3s single-node module for PipelineGuard
# Replaces the managed EKS cluster + node group with one self-managed k3s
# node: no EKS control plane fee, one instance instead of a node group, and
# it lives in a public subnet so no NAT gateway is required either. Trades
# managed control plane HA/upgrades for a much cheaper on-demand demo cost -
# acceptable for a short-lived, spin-up/tear-down environment.

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Instance IAM role. SSM Session Manager is used for shell access instead of
# SSH, so there's no key pair to manage and no port 22 to expose.
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_instance_profile" "node" {
  name = "${var.cluster_name}-node-profile"
  role = aws_iam_role.node.name
}

resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for the k3s node"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.nodeports
    content {
      description = "NodePort ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.allowed_http_cidr]
    }
  }

  dynamic "ingress" {
    for_each = var.public_nodeports
    content {
      description = "Public NodePort ${ingress.value} (e.g. ACME HTTP-01)"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound (image pulls, GitHub, SSM)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-node-sg"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_instance" "node" {
  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.node.id]
  iam_instance_profile   = aws_iam_instance_profile.node.name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    dnf install -y docker git
    systemctl enable --now docker
    usermod -aG docker ec2-user

    # Proactively garbage-collect container images well before the default
    # hard disk-pressure eviction threshold (~85%) - this is a single small
    # (gp3) node, and a burst of image pulls across several Deployments in
    # a short window can otherwise transiently trip DiskPressure, which
    # taints the node NoSchedule for kubelet's ~5min hysteresis window even
    # though real usage never got close to actually running out of space.
    mkdir -p /etc/rancher/k3s
    cat > /etc/rancher/k3s/config.yaml <<'K3S_CONFIG'
    kubelet-arg:
      - "image-gc-high-threshold=70"
      - "image-gc-low-threshold=50"
    K3S_CONFIG

    curl -sfL https://get.k3s.io | sh -

    until /usr/local/bin/k3s kubectl --kubeconfig=/etc/rancher/k3s/k3s.yaml get nodes 2>/dev/null; do
      sleep 5
    done

    mkdir -p /home/ec2-user/.kube
    cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
    chown -R ec2-user:ec2-user /home/ec2-user/.kube
    echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' > /etc/profile.d/k3s.sh
  EOF

  tags = {
    Name        = var.cluster_name
    Project     = var.project
    Environment = var.environment
  }
}
