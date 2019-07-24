#!/bin/bash

# Install kubernetes from scratch
# CentOS, RHEL or Fedora

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/


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

# disable swap
swapoff -a

# Init kubeadm
kubeadm init --ignore-preflight-errors all

# Make kubectl work for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#####################################################
# TODO: add this to /etc/profile
export KUBECONFIG=/etc/kubernetes/admin.conf
#####################################################

# Set /proc/sys/net/bridge/bridge-nf-call-iptables to 1
sysctl net.bridge.bridge-nf-call-iptables=1

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"