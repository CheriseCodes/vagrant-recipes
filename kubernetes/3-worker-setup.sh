set -x
NODE_IP=$1

# Set specific internal node ip
systemctl daemon-reload
echo "KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP --cgroup-driver=systemd" > /etc/default/kubelet
systemctl restart kubelet

