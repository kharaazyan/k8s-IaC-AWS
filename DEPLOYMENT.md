<div align="center">

# 🚀 Deployment Guide

### **Complete Step-by-Step Kubernetes Infrastructure Deployment**

[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)

*Comprehensive deployment guide for setting up a production-ready Kubernetes cluster on AWS using Terraform and kubeadm*

[🚀 Quick Start](#-quick-start) • [📋 Prerequisites](#-prerequisites) • [🔧 Installation](#-installation) • [🐳 Kubernetes Setup](#-kubernetes-setup) • [📊 Monitoring](#-monitoring) • [🧪 Testing](#-testing) • [🔄 Scaling](#-scaling) • [🛠️ Troubleshooting](#️-troubleshooting) • [🧹 Cleanup](#-cleanup)

---

</div>

## 🎯 Deployment Overview

This guide provides a comprehensive walkthrough for deploying a **production-ready Kubernetes cluster** on AWS infrastructure. The deployment process is divided into several phases, each building upon the previous to create a robust and scalable Kubernetes environment.

### 🎯 Deployment Phases

<div align="center">

| Phase | Duration | Description | Status |
|-------|----------|-------------|--------|
| **🔧 Prerequisites** | 15-30 min | Tool installation and AWS setup | ⏳ Manual |
| **🚀 Infrastructure** | 10-15 min | Terraform deployment | ⚡ Automated |
| **🐳 Kubernetes** | 20-30 min | Cluster initialization | ⚡ Automated |
| **📊 Monitoring** | 10-15 min | Health checks and verification | ⚡ Automated |
| **🧪 Testing** | 15-20 min | Application deployment testing | ⚡ Automated |

</div>

---

## 🚀 Quick Start

### ⚡ One-Command Deployment

<div align="center">

**For experienced users who want to deploy quickly:**

</div>

```bash
# Complete deployment in one go
git clone <repository-url> && cd k8s && \
cp terraform.tfvars.example terraform.tfvars && \
# Edit terraform.tfvars with your credentials, then:
terraform init && terraform apply -auto-approve && \
MASTER_IP=$(terraform output -raw public-ip-master-01) && \
echo "🚀 Infrastructure deployed! SSH to master: ssh -i your-key.pem ubuntu@$MASTER_IP"
```

### 🎯 Expected Timeline

<div align="center">

| Step | Time | Description |
|------|------|-------------|
| **Infrastructure** | 10-15 min | VPC, EC2 instances, networking |
| **Kubernetes Setup** | 20-30 min | kubeadm initialization |
| **Verification** | 5-10 min | Cluster health checks |
| **Total** | **35-55 min** | Complete deployment |

</div>

---

## 📋 Prerequisites

### 🛠️ Required Tools

<div align="center">

| Tool | Version | Installation Method | Verification |
|------|---------|-------------------|--------------|
| **Terraform** | `>= 1.0` | [Download](https://www.terraform.io/downloads.html) | `terraform version` |
| **AWS CLI** | `>= 2.0` | [Install Guide](https://aws.amazon.com/cli/) | `aws --version` |
| **kubectl** | `>= 1.25` | [Install Guide](https://kubernetes.io/docs/tasks/tools/) | `kubectl version` |

</div>

### 🔧 Tool Installation

<details>
<summary><b>🔧 Terraform Installation</b></summary>

#### **Ubuntu/Debian**
```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs)"

# Install Terraform
sudo apt-get update && sudo apt-get install terraform

# Verify installation
terraform version
```

#### **macOS**
```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform version
```

#### **Windows**
```bash
# Using Chocolatey
choco install terraform

# Or download from official website
# https://www.terraform.io/downloads.html
```

</details>

<details>
<summary><b>🔧 AWS CLI Installation</b></summary>

#### **All Platforms**
```bash
# Download AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Extract and install
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version

# Configure AWS CLI
aws configure
```

</details>

<details>
<summary><b>🔧 kubectl Installation</b></summary>

#### **Linux/macOS**
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable and move to PATH
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

#### **Windows**
```bash
# Using Chocolatey
choco install kubernetes-cli

# Or download from official website
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
```

</details>

### ☁️ AWS Requirements

<div align="center">

| Requirement | Description | Verification |
|-------------|-------------|--------------|
| **AWS Account** | Active AWS account with billing enabled | AWS Console access |
| **IAM Permissions** | EC2, VPC, IAM, and related permissions | `aws sts get-caller-identity` |
| **Key Pair** | SSH key pair for instance access | `aws ec2 describe-key-pairs` |
| **Service Quotas** | Sufficient limits for selected instance types | AWS Service Quotas console |

</div>

### 🔐 AWS Configuration

<details>
<summary><b>🔐 AWS Credentials Setup</b></summary>

#### **Option A: Environment Variables (Recommended)**
```bash
# Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-central-1"

# Verify configuration
aws sts get-caller-identity
```

#### **Option B: AWS CLI Configuration**
```bash
# Configure AWS CLI
aws configure

# Enter your credentials when prompted:
# AWS Access Key ID: your-access-key
# AWS Secret Access Key: your-secret-key
# Default region name: eu-central-1
# Default output format: json
```

#### **Option C: Terraform Variables File**
```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your credentials
nano terraform.tfvars

# Content should include:
aws_access_key = "your-access-key"
aws_secret_key = "your-secret-key"
```

</details>

---

## 🔧 Installation

### 📁 Repository Setup

```bash
# Clone the repository
git clone <repository-url>
cd k8s

# Verify files are present
ls -la
```

### 🔧 Terraform Configuration

<details>
<summary><b>🔧 1. Initialize Terraform</b></summary>

```bash
# Initialize Terraform
terraform init

# Expected output:
# Terraform has been successfully initialized!
# 
# You may now begin working with Terraform. Try running "terraform plan" to see
# any changes that are required for your infrastructure.
```

</details>

<details>
<summary><b>🔧 2. Validate Configuration</b></summary>

```bash
# Validate Terraform configuration
terraform validate

# Expected output:
# Success! The configuration is valid.
```

</details>

<details>
<summary><b>🔧 3. Preview Changes</b></summary>

```bash
# Preview infrastructure changes
terraform plan

# Review the plan output carefully:
# - Number of resources to be created
# - Resource types and configurations
# - Estimated costs (if available)
```

</details>

<details>
<summary><b>🔧 4. Deploy Infrastructure</b></summary>

```bash
# Deploy the infrastructure
terraform apply

# When prompted, type 'yes' to confirm
# 
# Expected output:
# Apply complete! Resources: X added, 0 changed, 0 destroyed.
# 
# Outputs:
# 
# public-ip-master-01 = "X.X.X.X"
# public-ip-worker-01 = "X.X.X.X"
# public-ip-worker-02 = "X.X.X.X"
```

</details>

### 📊 Deployment Verification

```bash
# Get deployment outputs
terraform output

# Verify AWS resources
aws ec2 describe-instances --filters "Name=tag:Name,Values=master-01,worker-01,worker-02" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0],PublicIpAddress]' --output table

# Check security groups
aws ec2 describe-security-groups --group-names k8s-sg --query 'SecurityGroups[*].[GroupName,GroupId,Description]' --output table
```

---

## 🐳 Kubernetes Setup

### 🎯 Cluster Initialization

<div align="center">

**After infrastructure deployment, initialize the Kubernetes cluster:**

</div>

<details>
<summary><b>🐳 1. SSH to Master Node</b></summary>

```bash
# Get master node IP
MASTER_IP=$(terraform output -raw public-ip-master-01)
echo "Master IP: $MASTER_IP"

# SSH to master node
ssh -i your-key.pem ubuntu@$MASTER_IP

# Verify you're on the master node
hostname
# Expected output: master-01
```

</details>

<details>
<summary><b>🐳 2. Initialize Kubernetes Cluster</b></summary>

```bash
# Initialize the cluster with kubeadm
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) \
  --upload-certs

# Expected output:
# Your Kubernetes control-plane has initialized successfully!
# 
# To start using your cluster, you need to run the following as a regular user:
# 
#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 
# You should now deploy a pod network to the cluster. Run "kubectl apply -f <pod-network-url>" and they will provide you with the exact URL to use.
# 
# You can now join any number of the control-plane node running the following command on each as root:
# 
#   kubeadm join 10.0.0.X:6443 --token <token> \
#     --discovery-token-ca-cert-hash sha256:<hash> \
#     --control-plane --certificate-key <cert-key>
# 
# Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
# As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
# "kubeadm init phase upload-certs --upload-certs" to reload certs afterward.
# 
# Then you can join any number of worker nodes by running the following on each as root:
# 
#   kubeadm join 10.0.0.X:6443 --token <token> \
#     --discovery-token-ca-cert-hash sha256:<hash>
```

</details>

<details>
<summary><b>🐳 3. Configure kubectl</b></summary>

```bash
# Create .kube directory
mkdir -p $HOME/.kube

# Copy admin configuration
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Set proper ownership
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verify kubectl configuration
kubectl cluster-info
kubectl get nodes

# Expected output:
# NAME       STATUS     ROLES           AGE   VERSION
# master-01  NotReady   control-plane   1m    v1.33.0
```

</details>

<details>
<summary><b>🐳 4. Install CNI (Container Network Interface)</b></summary>

```bash
# Install Flannel CNI
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Wait for CNI pods to be ready
kubectl get pods -n kube-system

# Expected output (after a few minutes):
# NAME                    READY   STATUS    RESTARTS   AGE
# kube-flannel-ds-xxxxx   1/1     Running   0          2m
# kube-flannel-ds-xxxxx   1/1     Running   0          2m
# kube-flannel-ds-xxxxx   1/1     Running   0          2m
```

</details>

### 🔗 Worker Node Joining

<details>
<summary><b>🔗 1. Get Join Command</b></summary>

```bash
# On master node, get the join command
sudo kubeadm token create --print-join-command

# Expected output:
# kubeadm join 10.0.0.X:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

</details>

<details>
<summary><b>🔗 2. Join Worker Nodes</b></summary>

```bash
# SSH to worker-01
WORKER1_IP=$(terraform output -raw public-ip-worker-01)
ssh -i your-key.pem ubuntu@$WORKER1_IP

# Run join command (replace with actual command from step 1)
sudo kubeadm join 10.0.0.X:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# SSH to worker-02
WORKER2_IP=$(terraform output -raw public-ip-worker-02)
ssh -i your-key.pem ubuntu@$WORKER2_IP

# Run join command
sudo kubeadm join 10.0.0.X:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

</details>

<details>
<summary><b>🔗 3. Verify Cluster</b></summary>

```bash
# Back on master node, verify all nodes joined
kubectl get nodes

# Expected output:
# NAME       STATUS   ROLES           AGE   VERSION
# master-01  Ready    control-plane   10m   v1.33.0
# worker-01  Ready    <none>          5m    v1.33.0
# worker-02  Ready    <none>          3m    v1.33.0

# Check all pods are running
kubectl get pods --all-namespaces

# Expected output:
# NAMESPACE     NAME                                    READY   STATUS    RESTARTS   AGE
# kube-system   coredns-xxxxx-xxxxx                     1/1     Running   0          10m
# kube-system   kube-apiserver-master-01                1/1     Running   0          10m
# kube-system   kube-controller-manager-master-01       1/1     Running   0          10m
# kube-system   kube-flannel-ds-xxxxx                   1/1     Running   0          8m
# kube-system   kube-proxy-xxxxx                        1/1     Running   0          10m
# kube-system   kube-scheduler-master-01                1/1     Running   0          10m
```

</details>

---

## 📊 Monitoring and Verification

### 🔍 Cluster Health Check

<div align="center">

**Verify your cluster is healthy and ready for workloads:**

</div>

```bash
# Check node status
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info

# Check component status
kubectl get componentstatuses
```

### 🌐 Network Verification

<details>
<summary><b>🌐 1. DNS Resolution Test</b></summary>

```bash
# Test DNS resolution
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Expected output:
# Server:    10.96.0.10
# Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local
# 
# Name:      kubernetes.default
# Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

</details>

<details>
<summary><b>🌐 2. Service Connectivity Test</b></summary>

```bash
# Test service connectivity
kubectl run test-connectivity --image=busybox --rm -it --restart=Never -- wget -qO- http://kubernetes.default

# Expected output:
# {
#   "kind": "APIVersions",
#   "versions": [
#     "v1"
#   ],
#   "serverAddressByClientCIDRs": [
#     {
#       "clientCIDR": "0.0.0.0/0",
#       "serverAddress": "10.0.0.X:6443"
#     }
#   ]
# }
```

</details>

### 📈 Resource Monitoring

```bash
# Install metrics server (optional but recommended)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Wait for metrics server to be ready
kubectl get pods -n kube-system | grep metrics-server

# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

---

## 🧪 Testing the Deployment

### 🎯 Application Deployment Test

<div align="center">

**Deploy a test application to verify your cluster is working correctly:**

</div>

<details>
<summary><b>🧪 1. Deploy Test Application</b></summary>

```bash
# Create test namespace
kubectl create namespace test

# Deploy nginx application
kubectl run nginx --image=nginx --port=80 -n test

# Create service
kubectl expose pod nginx --port=80 --target-port=80 -n test

# Check deployment status
kubectl get pods,svc -n test

# Expected output:
# NAME        READY   STATUS    RESTARTS   AGE
# pod/nginx   1/1     Running   0          30s
# 
# NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
# service/nginx   ClusterIP   10.96.123.45    <none>        80/TCP    20s
```

</details>

<details>
<summary><b>🧪 2. Test Application Access</b></summary>

```bash
# Test internal access
kubectl run test-client --image=busybox --rm -it --restart=Never -n test -- wget -qO- http://nginx

# Expected output:
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# ...

# Test from within the cluster
kubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -n test -- curl http://nginx
```

</details>

<details>
<summary><b>🧪 3. Node Affinity Test</b></summary>

```bash
# Deploy pod to specific node
kubectl run test-pod --image=busybox \
  --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"worker-01"}}}' \
  --rm -it --restart=Never -- sleep 30

# Verify pod placement
kubectl get pod test-pod -o wide

# Expected output:
# NAME      READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
# test-pod  1/1     Running   0          10s   10.244.1.2   worker-01  <none>           <none>
```

</details>

### 🎯 Load Testing

```bash
# Deploy multiple replicas
kubectl create deployment nginx-deployment --image=nginx --replicas=3 -n test

# Scale the deployment
kubectl scale deployment nginx-deployment --replicas=5 -n test

# Check pod distribution across nodes
kubectl get pods -n test -o wide

# Monitor resource usage
kubectl top pods -n test
```

---

## 🔄 Scaling Operations

### 📈 Adding Worker Nodes

<div align="center">

**Scale your cluster by adding more worker nodes:**

</div>

<details>
<summary><b>📈 1. Update Terraform Configuration</b></summary>

```hcl
# Add new worker instance in ec2.tf
resource "aws_instance" "worker-03" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pub-sub.id
  key_name               = data.aws_key_pair.secret-key.key_name
  vpc_security_group_ids = [aws_security_group.k8s-sg.id]
  
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
    delete_on_termination = true
  }
  
  user_data = <<-EOF
    # Same user_data as other workers
    # ... (copy from worker-01 or worker-02)
  EOF
  
  tags = {
    Name = "worker-03"
  }
}

# Add output for new worker
output "public-ip-worker-03" {
  description = "Public IP of worker-03"
  value       = aws_instance.worker-03.public_ip
}
```

</details>

<details>
<summary><b>📈 2. Deploy New Infrastructure</b></summary>

```bash
# Plan the changes
terraform plan

# Apply the changes
terraform apply

# Verify new instance
terraform output public-ip-worker-03
```

</details>

<details>
<summary><b>📈 3. Join New Node to Cluster</b></summary>

```bash
# Get join command from master
sudo kubeadm token create --print-join-command

# SSH to new worker and join
WORKER3_IP=$(terraform output -raw public-ip-worker-03)
ssh -i your-key.pem ubuntu@$WORKER3_IP

# Run join command
sudo kubeadm join 10.0.0.X:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# Verify node joined
kubectl get nodes
```

</details>

### 🔄 Kubernetes Version Upgrade

<details>
<summary><b>🔄 1. Plan the Upgrade</b></summary>

```bash
# Check current version
kubectl version --short

# Plan upgrade path
# - Update AMI ID in var.tf
# - Update user_data scripts in ec2.tf
# - Redeploy infrastructure
# - Upgrade cluster using kubeadm
```

</details>

<details>
<summary><b>🔄 2. Upgrade Process</b></summary>

```bash
# On master node
sudo apt-get update
sudo apt-get install -y kubelet=1.33.1-00 kubeadm=1.33.1-00 kubectl=1.33.1-00

# Upgrade control plane
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.33.1

# Upgrade worker nodes (one by one)
# Drain node
kubectl drain worker-01 --ignore-daemonsets --delete-emptydir-data

# SSH to worker and upgrade
sudo apt-get update
sudo apt-get install -y kubelet=1.33.1-00 kubeadm=1.33.1-00

# Uncordon node
kubectl uncordon worker-01
```

</details>

---

## 🛠️ Troubleshooting

### 🔍 Common Issues and Solutions

<div align="center">

**Quick reference for common deployment issues:**

</div>

<details>
<summary><b>❌ Terraform Issues</b></summary>

#### **Provider Not Found**
```bash
# Issue: Failed to query available provider packages
Error: Failed to query available provider packages

# Solution:
terraform init -upgrade
```

#### **Invalid Credentials**
```bash
# Issue: error configuring Terraform AWS Provider
Error: error configuring Terraform AWS Provider

# Solution:
aws configure
# or set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

#### **Insufficient Permissions**
```bash
# Issue: Access Denied errors
Error: AccessDenied: User: arn:aws:iam::123456789012:user/username is not authorized

# Solution: Add required IAM permissions
# - EC2FullAccess
# - VPCFullAccess
# - IAMFullAccess (or more restricted)
```

</details>

<details>
<summary><b>❌ Kubernetes Issues</b></summary>

#### **Node Not Ready**
```bash
# Check kubelet status
sudo systemctl status kubelet

# Check kubelet logs
sudo journalctl -u kubelet -f

# Check node conditions
kubectl describe node <node-name>

# Common solutions:
# - Check CNI installation
# - Verify system requirements
# - Check disk space
```

#### **Pods Stuck in Pending**
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes

# Check taints and tolerations
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Common solutions:
# - Add more resources
# - Remove taints
# - Check storage classes
```

#### **Network Connectivity Issues**
```bash
# Check CNI pods
kubectl get pods -n kube-system | grep flannel

# Check CNI logs
kubectl logs -n kube-system <flannel-pod-name>

# Test network connectivity
kubectl run test-net --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Common solutions:
# - Reinstall CNI
# - Check firewall rules
# - Verify CIDR configuration
```

</details>

<details>
<summary><b>❌ AWS Issues</b></summary>

#### **Instance Launch Failures**
```bash
# Check instance status
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Check instance logs
aws ec2 get-console-output --instance-id i-1234567890abcdef0

# Common causes:
# - Insufficient capacity
# - Invalid AMI
# - Security group issues
```

#### **Security Group Issues**
```bash
# Check security group rules
aws ec2 describe-security-groups --group-names k8s-sg

# Test connectivity
aws ec2 describe-instances --filters "Name=security-group.group-name,Values=k8s-sg"
```

#### **Key Pair Issues**
```bash
# Verify key pair exists
aws ec2 describe-key-pairs --key-names your-key-pair

# Create new key pair if needed
aws ec2 create-key-pair --key-name new-key-pair --query 'KeyMaterial' --output text > new-key-pair.pem
chmod 400 new-key-pair.pem
```

</details>

### 📊 Debug Commands

<div align="center">

**Essential debugging commands for troubleshooting:**

</div>

```bash
# Terraform debugging
terraform plan -detailed-exitcode
terraform validate
terraform state list

# Kubernetes debugging
kubectl get nodes -o wide
kubectl get pods --all-namespaces
kubectl describe node <node-name>
kubectl logs <pod-name> -n <namespace>
kubectl get events --sort-by='.lastTimestamp'

# AWS debugging
aws ec2 describe-instances --filters "Name=tag:Name,Values=master-01"
aws ec2 describe-security-groups --group-names k8s-sg
aws ec2 describe-vpcs --vpc-ids vpc-12345678

# System debugging
ssh -i your-key.pem ubuntu@<instance-ip> "sudo systemctl status kubelet"
ssh -i your-key.pem ubuntu@<instance-ip> "sudo journalctl -u kubelet -n 50"
```

---

## 🧹 Cleanup

### 🗑️ Infrastructure Destruction

<div align="center">

**Clean up all resources when no longer needed:**

</div>

<details>
<summary><b>🗑️ 1. Kubernetes Cleanup</b></summary>

```bash
# Remove all Kubernetes resources
kubectl delete all --all --all-namespaces

# Reset kubeadm on all nodes
# On master node:
sudo kubeadm reset

# On worker nodes:
sudo kubeadm reset

# Clean up iptables
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X
```

</details>

<details>
<summary><b>🗑️ 2. Terraform Destruction</b></summary>

```bash
# Destroy all Terraform resources
terraform destroy

# When prompted, type 'yes' to confirm

# Expected output:
# Destroy complete! Resources: X destroyed.
```

</details>

<details>
<summary><b>🗑️ 3. Verification</b></summary>

```bash
# Verify all resources are destroyed
aws ec2 describe-instances --filters "Name=tag:Name,Values=master-01,worker-01,worker-02"

# Check for any remaining resources
aws ec2 describe-security-groups --group-names k8s-sg
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=k8s-vpc"
```

</details>

### 🔄 Manual Cleanup (if needed)

```bash
# If Terraform destroy fails, manually remove resources
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
aws ec2 delete-security-group --group-name k8s-sg
aws ec2 delete-vpc --vpc-id vpc-12345678

# Remove local files
rm -rf .terraform
rm terraform.tfstate*
```

---

<div align="center">

### 🎉 Deployment Complete!

**Congratulations! You have successfully deployed a production-ready Kubernetes cluster on AWS.**

**Next Steps:**
- [📖 Read the Security Guide](SECURITY.md)
- [🔧 Configure monitoring and alerting](#-monitoring)
- [🧪 Deploy your applications](#-testing)
- [📈 Scale your infrastructure](#-scaling)

**🔧 Need Help?** Check the [Troubleshooting](#️-troubleshooting) section or create an issue in the repository.

[![Deployment](https://img.shields.io/badge/Deployment-Successful-green?style=for-the-badge&logo=check-circle&logoColor=white)](https://kubernetes.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

</div> 