#!/bin/bash

# Install kubernetes from scratch
# CentOS, RHEL or Fedora

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# Check if user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run this script as root"
  exit
fi

# Installing kubeadm, kubelet and kubectl
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet


# ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


# Update kubeadm
yum update -y

# Install docker
yum install -y docker
# Add current user to docker group
usermod -aG docker $(whoami)
# Run docker on startup
systemctl enable docker.service
# Start docker
systemctl start docker.service

# disable swap
swapoff -a

# disable firewalld
systemctl disable firewalld
systemctl stop firewalld

# Init kubeadm
kubeadm init --ignore-preflight-errors NumCPU

# Add KUBECONFIG variable to all users
echo export KUBECONFIG=/etc/kubernetes/admin.conf > /etc/profile.d/kubernetes.conf
source /etc/profile
source /etc/profile.d/kubernetes.conf

# Set /proc/sys/net/bridge/bridge-nf-call-iptables to 1
sysctl net.bridge.bridge-nf-call-iptables=1
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Control plane node isolation
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation
kubectl taint nodes --all node-role.kubernetes.io/master-
