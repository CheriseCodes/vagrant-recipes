# First disable swap
set -x

swapoff -a

# And then to disable swap on startup in /etc/fstab
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Update the apt package index and install packages needed to use the Kubernetes apt repository
apt-get update
apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key
mkdir -m 0755 -p /etc/apt/keyrings
# curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# SKIP - NO LONGER WORKING: Add the Kubernetes apt repository
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index again, install kubelet, kubeadm and kubectl, pin their version to avoid auto-upgrade
# TODO: Fix error from here
# apt-get update
# apt-get install -y kubelet kubeadm kubectl
# apt-mark hold kubelet kubeadm kubectl
# TODO: Maybe skip last lines and do
# Update the apt package index and install packages needed to use the Kubernetes apt repository
apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
apt-get install -y apt-transport-https ca-certificates curl gpg

# If the directory `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below
# mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Install kube tools
# TODO: Allow user to specify version
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet
