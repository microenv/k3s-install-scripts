# Kubernetes Install Scripts

> Bash scripts to install kubernetes on linux without the need for configuration

Work in progress

## Install kubernetes only

To install kubernetes in a single control-plane cluster, run:

**Become a super user**

```
sudo su
```

**Then run the following command**

```
curl -s https://raw.githubusercontent.com/microenv/k3s-install-scripts/master/install-k3s.sh | bash -s && sudo source /etc/profile && sudo /etc/profile.d/kubernetes.conf
```
