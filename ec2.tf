resource "aws_instance" "master-01" {
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
                  #!/usr/bin/env bash
                  set -euxo pipefail
                  sudo hostnamectl set-hostname master-01
                  # Versions
                  CNI_VERSION="v1.3.0"
                  CRICTL_VERSION="v1.31.0"
                  ARCH="amd64"

                  ############ 0. Disable swap permanently ############
                  swapoff -a
                  sed -i '/ swap / s/^/#/' /etc/fstab

                  ############ 1. Kernel prereqs ############
                  cat <<K8S_MODS >/etc/modules-load.d/k8s.conf
                  overlay
                  br_netfilter
                  K8S_MODS

                  modprobe overlay
                  modprobe br_netfilter

                  cat <<K8S_SYS >/etc/sysctl.d/99-kubernetes-cri.conf
                  net.ipv4.ip_forward                 = 1
                  net.bridge.bridge-nf-call-iptables  = 1
                  net.bridge.bridge-nf-call-ip6tables = 1
                  K8S_SYS
                  sysctl --system

                  ############ 2. containerd + systemd-cgroup ############
                  apt-get update -y
                  apt-get install -y containerd ca-certificates curl gpg

                  mkdir -p /etc/containerd
                  containerd config default | tee /etc/containerd/config.toml
                  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
                  systemctl restart containerd
                  systemctl enable containerd

                  ############ 3. CNI plugins + crictl ############
                  mkdir -p /opt/cni/bin
                  curl -L "https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-linux-$${ARCH}-$${CNI_VERSION}.tgz" \
                    | tar -C /opt/cni/bin -xz
                  curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/$${CRICTL_VERSION}/crictl-$${CRICTL_VERSION}-linux-$${ARCH}.tar.gz" \
                    | tar -C /usr/local/bin -xz

                  ############ 4. Kubernetes repo + binaries ############
                  mkdir -p /etc/apt/keyrings
                  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
                    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' \
                    > /etc/apt/sources.list.d/kubernetes.list

                  apt-get update -y
                  apt-get install -y kubelet kubeadm kubectl
                  apt-mark hold kubelet kubeadm kubectl
                  systemctl enable --now kubelet   # will crash-loop until 'kubeadm init' or 'join'

                  echo "=== NODE READY: run 'kubeadm init' or 'kubeadm join' next ==="
                EOF
  tags = {
    Name = "master-01"
  }
}

resource "aws_instance" "worker-01" {
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
                  #!/usr/bin/env bash
                  set -euxo pipefail
                  sudo hostnamectl set-hostname worker-01

                  # Versions
                  CNI_VERSION="v1.3.0"
                  CRICTL_VERSION="v1.31.0"
                  ARCH="amd64"

                  ############ 0. Disable swap permanently ############
                  swapoff -a
                  sed -i '/ swap / s/^/#/' /etc/fstab

                  ############ 1. Kernel prereqs ############
                  cat <<K8S_MODS >/etc/modules-load.d/k8s.conf
                  overlay
                  br_netfilter
                  K8S_MODS

                  modprobe overlay
                  modprobe br_netfilter

                  cat <<K8S_SYS >/etc/sysctl.d/99-kubernetes-cri.conf
                  net.ipv4.ip_forward                 = 1
                  net.bridge.bridge-nf-call-iptables  = 1
                  net.bridge.bridge-nf-call-ip6tables = 1
                  K8S_SYS
                  sysctl --system

                  ############ 2. containerd + systemd-cgroup ############
                  apt-get update -y
                  apt-get install -y containerd ca-certificates curl gpg

                  mkdir -p /etc/containerd
                  containerd config default | tee /etc/containerd/config.toml
                  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
                  systemctl restart containerd
                  systemctl enable containerd

                  ############ 3. CNI plugins + crictl ############
                  mkdir -p /opt/cni/bin
                  curl -L "https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-linux-$${ARCH}-$${CNI_VERSION}.tgz" \
                    | tar -C /opt/cni/bin -xz
                  curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/$${CRICTL_VERSION}/crictl-$${CRICTL_VERSION}-linux-$${ARCH}.tar.gz" \
                    | tar -C /usr/local/bin -xz

                  ############ 4. Kubernetes repo + binaries ############
                  mkdir -p /etc/apt/keyrings
                  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
                    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' \
                    > /etc/apt/sources.list.d/kubernetes.list

                  apt-get update -y
                  apt-get install -y kubelet kubeadm kubectl
                  apt-mark hold kubelet kubeadm kubectl
                  systemctl enable --now kubelet   # will crash-loop until 'kubeadm init' or 'join'

                  echo "=== NODE READY: run 'kubeadm init' or 'kubeadm join' next ==="
                EOF
  tags = {
    Name = "worker-01"
  }
}

resource "aws_instance" "worker-02" {
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
                  #!/usr/bin/env bash
                  set -euxo pipefail
                  sudo hostnamectl set-hostname worker-02
                  # Versions
                  CNI_VERSION="v1.3.0"
                  CRICTL_VERSION="v1.31.0"
                  ARCH="amd64"

                  ############ 0. Disable swap permanently ############
                  swapoff -a
                  sed -i '/ swap / s/^/#/' /etc/fstab

                  ############ 1. Kernel prereqs ############
                  cat <<K8S_MODS >/etc/modules-load.d/k8s.conf
                  overlay
                  br_netfilter
                  K8S_MODS

                  modprobe overlay
                  modprobe br_netfilter

                  cat <<K8S_SYS >/etc/sysctl.d/99-kubernetes-cri.conf
                  net.ipv4.ip_forward                 = 1
                  net.bridge.bridge-nf-call-iptables  = 1
                  net.bridge.bridge-nf-call-ip6tables = 1
                  K8S_SYS
                  sysctl --system

                  ############ 2. containerd + systemd-cgroup ############
                  apt-get update -y
                  apt-get install -y containerd ca-certificates curl gpg

                  mkdir -p /etc/containerd
                  containerd config default | tee /etc/containerd/config.toml
                  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
                  systemctl restart containerd
                  systemctl enable containerd

                  ############ 3. CNI plugins + crictl ############
                  mkdir -p /opt/cni/bin
                  curl -L "https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-linux-$${ARCH}-$${CNI_VERSION}.tgz" \
                    | tar -C /opt/cni/bin -xz
                  curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/$${CRICTL_VERSION}/crictl-$${CRICTL_VERSION}-linux-$${ARCH}.tar.gz" \
                    | tar -C /usr/local/bin -xz

                  ############ 4. Kubernetes repo + binaries ############
                  mkdir -p /etc/apt/keyrings
                  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key \
                    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' \
                    > /etc/apt/sources.list.d/kubernetes.list

                  apt-get update -y
                  apt-get install -y kubelet kubeadm kubectl
                  apt-mark hold kubelet kubeadm kubectl
                  systemctl enable --now kubelet   # will crash-loop until 'kubeadm init' or 'join'

                  echo "=== NODE READY: run 'kubeadm init' or 'kubeadm join' next ==="
                EOF
  tags = {
    Name = "worker-02"
  }
}

output "public-ip-master-01" {
  description = "Public IP: "
  value       = aws_instance.master-01.public_ip
}

output "public-ip-worker-01" {
  description = "Public IP: "
  value       = aws_instance.worker-01.public_ip
}

output "public-ip-worker-02" {
  description = "Public IP: "
  value       = aws_instance.worker-02.public_ip
}

output "private-ip-master-01" {
  description = "Public IP: "
  value       = aws_instance.master-01.private_ip
}

output "private-ip-worker-01" {
  description = "Public IP: "
  value       = aws_instance.worker-01.private_ip
}

output "private-ip-worker-02" {
  description = "Public IP: "
  value       = aws_instance.worker-02.private_ip
}