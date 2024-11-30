# TODO: Compare to most recent script: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
set -x

# Load kernel modules in Linux
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Verify that the overlay, br_netfilter modules are loaded
lsmod | grep overlay
lsmod | grep br_netfilter

# Forwarding IPv4 and letting iptables see bridged traffic
# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, net.ipv4.ip_forward system variables are set to 1
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
apt-get update

apt-get install \
ca-certificates \
curl \
gnupg \
lsb-release

# Add Docker’s official GPG key:
mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# set up the repository:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update

# Install the latest version package containerd.io
apt-get install containerd.io

# Replace containered config
cat <<EOF | tee /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
         SystemdCgroup = true 
EOF

systemctl restart containerd
