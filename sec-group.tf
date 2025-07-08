resource "aws_security_group" "k8s-sg" {
  name        = "k8s-security-group-${var.environment}"
  description = "Security group for Kubernetes cluster with minimal required access"
  vpc_id      = aws_vpc.k8s-vpc.id
  depends_on  = [aws_vpc.k8s-vpc]

  # SSH Access (Port 22) - Configurable via variables
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_ips
    description = "SSH access for administration"
  }

  # Kubernetes API Server (Port 6443) - Configurable via variables
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.allowed_api_ips
    description = "Kubernetes API server access"
  }

  # etcd Client Communication (Port 2379-2380)
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
    description = "etcd client communication between nodes"
  }

  # Kubernetes Kubelet API (Port 10250)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
    description = "Kubelet API for node communication"
  }

  # Kubernetes Kube-Proxy Health Check (Port 10256)
  ingress {
    from_port   = 10256
    to_port     = 10256
    protocol    = "tcp"
    self        = true
    description = "Kube-proxy health check"
  }

  # NodePort Services (Port 30000-32767) - TCP
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort services access (TCP)"
  }

  # NodePort Services (Port 30000-32767) - UDP
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort services access (UDP)"
  }

  # ICMP for network troubleshooting
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ICMP for network troubleshooting"
  }

  # All outbound traffic (required for internet access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "k8s-security-group-${var.environment}"
    Environment = var.environment
    Purpose     = "kubernetes-cluster"
    ManagedBy   = "terraform"
  }
}

# Production-ready security group with restricted access
# Uncomment and use this for production environments
/*
resource "aws_security_group" "k8s-sg-production" {
  name        = "k8s-security-group-production"
  description = "Production security group for Kubernetes cluster with restricted access"
  vpc_id      = aws_vpc.k8s-vpc.id
  depends_on  = [aws_vpc.k8s-vpc]

  # SSH Access - Restricted to specific IPs
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "YOUR_OFFICE_IP/32",    # Replace with your office IP
      "YOUR_HOME_IP/32",      # Replace with your home IP
      "YOUR_VPN_IP/32"        # Replace with your VPN IP
    ]
    description = "SSH access from authorized IPs only"
  }

  # Kubernetes API Server - Restricted to admin IPs
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [
      "YOUR_ADMIN_IP/32"      # Replace with admin IP
    ]
    description = "Kubernetes API server access from admin IPs"
  }

  # Internal node communication
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
    description = "Internal node-to-node communication"
  }

  # NodePort Services - Optional, remove if not needed
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort services access"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "k8s-security-group-production"
    Environment = "production"
    Purpose     = "kubernetes-cluster"
    ManagedBy   = "terraform"
  }
}
*/