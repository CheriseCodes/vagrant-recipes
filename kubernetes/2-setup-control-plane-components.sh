# TODO: Automate getting public IP address
sudo kubeadm init --apiserver-advertise-address=192.168.56.2 --pod-network-cidr=10.244.0.0/16
# TODO: Automate getting join command from the output

# TODO: If id -u is not 0  (not root)
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Run join command on worker nodes
sudo kubeadm join 192.168.56.2:6443 --token eow5ta.2qz5kyhvp2kpu8ta \
        --discovery-token-ca-cert-hash sha256:3620ca233b7e1cabd57699f7793da9c969802b00b84f3e24d152f965df1c0021

# (Optional) Verify installation by comparing netstat tables (review blog results)
sudo netstat -lntp

# Install a CNI to activate CoreDNS: https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy
# TODO: Replace 1.30 with user's kubernetes version
# TODO: Figure out why coredns can't be created 
kubectl apply -f https://reweave.azurewebsites.net/k8s/v1.30/net.yaml 
