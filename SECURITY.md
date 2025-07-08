<div align="center">

# 🔐 Security Guidelines

### **Comprehensive Security Framework for Kubernetes Infrastructure**

[![Security](https://img.shields.io/badge/Security-Critical-red?style=for-the-badge&logo=shield-check&logoColor=white)](https://owasp.org/)
[![AWS Security](https://img.shields.io/badge/AWS_Security-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/security/)
[![Terraform Security](https://img.shields.io/badge/Terraform_Security-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/docs/cloud/sentinel/)

*Essential security practices, guidelines, and best practices for securing your Kubernetes infrastructure on AWS*

[🔐 Critical Issues](#-critical-security-issues) • [🛡️ Best Practices](#️-security-best-practices) • [🚨 Emergency Response](#-emergency-response) • [📋 Security Checklist](#-security-checklist) • [🔍 Security Tools](#-security-tools) • [📞 Security Contacts](#-security-contacts)

---

</div>

## 🚨 Critical Security Issues Fixed

### ✅ AWS Credentials Security

<div align="center">

| Issue | Status | Action Required |
|-------|--------|-----------------|
| **🔴 Hardcoded Credentials** | ✅ **FIXED** | **IMMEDIATE ACTION REQUIRED** |
| **🔴 Exposed Access Keys** | ✅ **FIXED** | Deactivate old credentials |
| **🔴 Secret Key Exposure** | ✅ **FIXED** | Create new credentials |

</div>

#### 🎯 What Was Fixed

- **❌ Before**: Hardcoded AWS credentials in `my-provider.tf`
- **✅ After**: Secure variable-based configuration with `sensitive = true`

#### 🚨 Immediate Actions Required

1. **🔴 CRITICAL**: Deactivate exposed credentials in AWS Console
   ```bash
   # Check for unauthorized activity
   aws cloudtrail lookup-events --lookup-attributes AttributeKey=Username,AttributeValue=AKIA3NC5KT4PWK3UKBGC
   ```

2. **🔄 Create New Credentials**
   ```bash
   # Generate new access keys
   aws iam create-access-key --user-name your-username
   ```

3. **🔐 Secure Configuration**
   ```bash
   # Use environment variables (Recommended)
   export AWS_ACCESS_KEY_ID="new-access-key"
   export AWS_SECRET_ACCESS_KEY="new-secret-key"
   ```

### ✅ Sensitive Files Protection

<div align="center">

| File Type | Risk Level | Protection Status |
|-----------|------------|-------------------|
| **terraform.tfstate** | 🔴 **HIGH** | ✅ Excluded via .gitignore |
| **terraform.tfstate.backup** | 🔴 **HIGH** | ✅ Excluded via .gitignore |
| **.terraform/** | 🟡 **MEDIUM** | ✅ Excluded via .gitignore |
| ***.tfvars** | 🟡 **MEDIUM** | ✅ Excluded via .gitignore |

</div>

---

## 🛡️ Security Best Practices

### 🔐 1. Credential Management

<div align="center">

#### **Recommended Approach: Environment Variables**

```bash
# Set environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="eu-central-1"

# Verify configuration
aws sts get-caller-identity
```

#### **Alternative Approach: Terraform Variables**

```hcl
# terraform.tfvars (NOT tracked by git)
aws_access_key = "your-access-key"
aws_secret_key = "your-secret-key"
```

</div>

### 🛡️ 2. Production Security Groups

<div align="center">

**Current Configuration**: Allows all traffic (0.0.0.0/0) - **⚠️ NOT PRODUCTION READY**

**Recommended Production Configuration**:

</div>

```hcl
resource "aws_security_group" "k8s-sg" {
  name        = "k8s-production-sg"
  description = "Production Kubernetes security group"
  vpc_id      = aws_vpc.k8s-vpc.id

  # SSH Access (Restrict to your IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your-office-ip/32", "your-home-ip/32"]
    description = "SSH access from authorized IPs"
  }

  # Kubernetes API Server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["your-admin-ip/32"]
    description = "Kubernetes API access"
  }

  # Node-to-Node Communication
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
    description = "Node-to-node communication"
  }

  # Kubernetes Service Ports
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort services"
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
    Name = "k8s-production-sg"
    Environment = "production"
  }
}
```

### 🌐 3. Network Security

<div align="center">

| Security Layer | Implementation | Production Status |
|----------------|----------------|-------------------|
| **VPC Isolation** | ✅ Implemented | ✅ Secure |
| **Private Subnets** | ⚠️ Manual Setup | 🔄 Recommended |
| **Network ACLs** | ❌ Not Configured | 🔄 Recommended |
| **VPC Flow Logs** | ❌ Not Enabled | 🔄 Recommended |
| **AWS WAF** | ❌ Not Configured | 🔄 For Web Apps |

</div>

#### 🏗️ Recommended Network Architecture

```hcl
# Private subnets for worker nodes
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1a"
  
  tags = {
    Name = "private-subnet"
    Type = "private"
  }
}

# NAT Gateway for private subnet internet access
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  
  tags = {
    Name = "main-nat-gateway"
  }
}
```

### 👤 4. IAM Best Practices

<div align="center">

#### **Principle of Least Privilege**

| IAM Component | Current Status | Recommendation |
|---------------|----------------|----------------|
| **Access Keys** | ⚠️ Used | 🔄 Use IAM Roles |
| **User Permissions** | ⚠️ Broad | 🔄 Restrict to minimum |
| **MFA** | ❌ Not Enabled | 🔄 Enable for all users |
| **Access Reviews** | ❌ Not Scheduled | 🔄 Monthly reviews |

</div>

#### 🔐 IAM Role Implementation

```hcl
# IAM Role for EC2 instances
resource "aws_iam_role" "k8s_node_role" {
  name = "k8s-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach minimal required policies
resource "aws_iam_role_policy_attachment" "k8s_node_policy" {
  role       = aws_iam_role.k8s_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
```

### 📊 5. Monitoring and Logging

<div align="center">

#### **Essential Monitoring Setup**

| Service | Purpose | Status |
|---------|---------|--------|
| **CloudTrail** | API call logging | 🔄 Manual Setup |
| **CloudWatch** | Resource monitoring | 🔄 Manual Setup |
| **AWS Config** | Compliance monitoring | 🔄 Manual Setup |
| **GuardDuty** | Threat detection | 🔄 Manual Setup |

</div>

#### 🔍 Enable CloudTrail

```bash
# Enable CloudTrail
aws cloudtrail create-trail \
  --name k8s-security-trail \
  --s3-bucket-name your-log-bucket \
  --include-global-service-events

# Start logging
aws cloudtrail start-logging --name k8s-security-trail
```

---

## 🚨 Emergency Response

### 🚨 Incident Response Plan

<div align="center">

#### **Immediate Response (0-1 hour)**

| Action | Priority | Command |
|--------|----------|---------|
| **Deactivate Credentials** | 🔴 Critical | AWS Console → IAM → Users |
| **Check CloudTrail** | 🔴 Critical | `aws cloudtrail lookup-events` |
| **Review Resources** | 🟡 High | `aws ec2 describe-instances` |
| **Notify Team** | 🟡 High | Internal communication |

</div>

### 🔄 Recovery Procedures

#### 1. **Credential Compromise**

```bash
# 1. Deactivate compromised credentials
aws iam update-access-key \
  --user-name your-username \
  --access-key-id COMPROMISED_KEY \
  --status Inactive

# 2. Create new credentials
aws iam create-access-key --user-name your-username

# 3. Update all systems
export AWS_ACCESS_KEY_ID="new-access-key"
export AWS_SECRET_ACCESS_KEY="new-secret-key"

# 4. Verify new credentials
aws sts get-caller-identity
```

#### 2. **Resource Compromise**

```bash
# 1. Identify compromised resources
aws ec2 describe-instances --filters "Name=state-name,Values=running"

# 2. Stop suspicious instances
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# 3. Review security groups
aws ec2 describe-security-groups --group-names k8s-sg

# 4. Restrict access
aws ec2 revoke-security-group-ingress \
  --group-name k8s-sg \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
```

### 📋 Post-Incident Actions

1. **📝 Document the Incident**
   - Timeline of events
   - Root cause analysis
   - Impact assessment
   - Lessons learned

2. **🔧 Implement Additional Security**
   - Enable MFA for all users
   - Implement stricter IAM policies
   - Enable additional monitoring
   - Review and update security groups

3. **🔄 Regular Reviews**
   - Monthly access reviews
   - Quarterly security audits
   - Annual penetration testing

---

## 📋 Security Checklist

<div align="center">

### **Pre-Deployment Security Checklist**

| Item | Status | Priority |
|------|--------|----------|
| **AWS credentials not hardcoded** | ✅ Complete | 🔴 Critical |
| **Sensitive files in .gitignore** | ✅ Complete | 🔴 Critical |
| **Security groups properly configured** | ⚠️ Basic | 🟡 High |
| **IAM roles implemented** | ❌ Not Done | 🟡 High |
| **CloudTrail enabled** | ❌ Not Done | 🟡 High |
| **VPC Flow Logs enabled** | ❌ Not Done | 🟡 Medium |
| **Regular security audits scheduled** | ❌ Not Done | 🟡 Medium |
| **Backup strategy implemented** | ❌ Not Done | 🟡 Medium |
| **Monitoring and alerting configured** | ❌ Not Done | 🟡 Medium |

</div>

### 🔄 Ongoing Security Maintenance

<div align="center">

| Task | Frequency | Last Done | Next Due |
|------|-----------|-----------|----------|
| **Access Key Rotation** | Quarterly | ❌ Never | 🔄 Due |
| **Security Group Review** | Monthly | ❌ Never | 🔄 Due |
| **IAM Permission Audit** | Monthly | ❌ Never | 🔄 Due |
| **CloudTrail Log Review** | Weekly | ❌ Never | 🔄 Due |
| **Vulnerability Assessment** | Quarterly | ❌ Never | 🔄 Due |

</div>

---

## 🔍 Security Tools

### 🛠️ Recommended Security Tools

<div align="center">

| Tool | Purpose | Installation |
|------|---------|--------------|
| **🔍 Checkov** | Infrastructure security scanning | `pip install checkov` |
| **🛡️ Trivy** | Container vulnerability scanning | `brew install trivy` |
| **🔐 AWS CLI** | AWS security management | [Install Guide](https://aws.amazon.com/cli/) |
| **📊 Terraform Sentinel** | Policy as code | [Terraform Cloud](https://www.terraform.io/cloud) |
| **🔍 AWS Security Hub** | Security findings aggregation | [AWS Console](https://console.aws.amazon.com/securityhub/) |

</div>

### 🔍 Security Scanning Commands

```bash
# Checkov security scan
checkov -d . --framework terraform

# Trivy vulnerability scan
trivy fs --security-checks vuln,config .

# Terraform security scan
terraform plan -detailed-exitcode

# AWS CLI security check
aws iam get-account-authorization-details

# Check for exposed secrets
grep -r "AKIA" . --exclude-dir=.terraform
grep -r "sk_" . --exclude-dir=.terraform
```

### 📊 Security Monitoring Setup

```bash
# Enable AWS Config
aws configservice start-configuration-recorder \
  --configuration-recorder-name default

# Enable GuardDuty
aws guardduty create-detector \
  --enable \
  --finding-publishing-frequency FIFTEEN_MINUTES

# Set up CloudWatch alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "UnauthorizedAPICalls" \
  --alarm-description "Monitor for unauthorized API calls" \
  --metric-name "UnauthorizedAPICalls" \
  --namespace "AWS/CloudTrail" \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold
```

---

## 📞 Security Contacts

<div align="center">

### **Emergency Contacts**

| Contact | Purpose | Response Time |
|---------|---------|---------------|
| **🔴 AWS Security** | [security@amazon.com](mailto:security@amazon.com) | 24 hours |
| **🔴 AWS Support** | [AWS Support Center](https://aws.amazon.com/support/) | 1-4 hours |
| **🟡 Terraform Security** | [security@hashicorp.com](mailto:security@hashicorp.com) | 48 hours |
| **🟡 GitHub Security** | [GitHub Security](https://github.com/security) | 72 hours |

</div>

### 🆘 Incident Reporting

<div align="center">

#### **Security Incident Report Template**

```markdown
## Security Incident Report

**Date**: [Date of incident]
**Severity**: [Critical/High/Medium/Low]
**Affected Systems**: [List affected resources]

### Incident Summary
[Brief description of what happened]

### Root Cause
[Analysis of why it happened]

### Impact Assessment
[What was affected and how]

### Actions Taken
[Steps taken to resolve]

### Lessons Learned
[How to prevent in future]

### Follow-up Actions
[Additional security measures to implement]
```

</div>

---

<div align="center">

### 🛡️ Security First, Always

**Remember**: Security is not a one-time task but an ongoing process. Regular reviews, updates, and monitoring are essential for maintaining a secure infrastructure.

**🔐 Stay Secure, Stay Vigilant**

[![Security](https://img.shields.io/badge/Security-Awareness-blue?style=for-the-badge&logo=shield-check&logoColor=white)](https://owasp.org/)
[![AWS Security](https://img.shields.io/badge/AWS_Security-Best_Practices-orange?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/security/)

</div> 