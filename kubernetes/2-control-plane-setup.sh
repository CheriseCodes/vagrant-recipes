set -x

NODE_IP=$1

# Initialize the cluster
kubeadm init --apiserver-advertise-address=192.168.56.2 --pod-network-cidr=172.18.0.0/16 --token-ttl 1s

# Set specific internal node ip
systemctl daemon-reload
echo "KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP --cgroup-driver=systemd" > /etc/default/kubelet
systemctl restart kubelet

# Export join command for worker nodes to use
kubeadm token create --print-join-command > /vagrant/2-join.sh

# Allow default vagrant user to use kubectl
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Allow root user to use kubectl
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

# Install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# TODO: Try calico: https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
# Install calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
wget https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml
sed -i 's~cidr: 192\.168\.0\.0/16~cidr: 172\.18\.0\.0/16~g' custom-resources.yaml
kubectl create -f custom-resources.yaml
# rm custom-resources.yaml
# kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# # Install cilium cli
# CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
# CLI_ARCH=amd64
# if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
# curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
# sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
# tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
# rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

# # Install cilium container network interface (CNI) to enable container networking
# curl -LO https://github.com/cilium/cilium/archive/main.tar.gz
# tar xzf main.tar.gz
# cd cilium-main/install/kubernetes
# helm install cilium ./cilium --namespace kube-system

# # cilium install --version 1.16.0
# #cilium status --wait
# #cilium connectivity test
