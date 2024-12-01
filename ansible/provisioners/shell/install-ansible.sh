apt-get update -y
apt-get upgrade -y
apt-get install software-properties-common -y
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y python3.12
sudo -u vagrant bash -c 'curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12'
sudo -u vagrant bash -c 'python3.12 -m pip install ansible'
export PATH=$PATH:/home/vagrant/.local/bin/
ssh-keygen -f /home/vagrant/.ssh/id_rsa -N ""
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa 
chown vagrant:vagrant /home/vagrant/.ssh/id_rsa.pub
cat /home/vagrant/.ssh/id_rsa.pub > /vagrant/id_rsa.pub

cat <<'EOF' > /home/vagrant/inventory.ini
[db]
postgres ansible_host=192.168.56.3

[cache]
redis ansible_host=192.168.56.4
EOF
chown vagrant:vagrant /home/vagrant/inventory.ini
