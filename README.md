# Kubernetes Install Scripts

> Bash scripts to install kubernetes on linux without the need for configuration

Work in progress

## Install kubernetes only

To install kubernetes in a single control-plane cluster:

**1. Become a super user**

The installation needs su privileges to run properly.

```
sudo su
```

**2. Install and configure kubeadm**

```
curl -s https://raw.githubusercontent.com/microenv/k3s-install-scripts/master/install-k3s.sh | bash -s
```

**3. Reboot**

You can wether reboot your machine or run the following command:

```
source /etc/profile && source /etc/profile.d/kubernetes.conf
```
