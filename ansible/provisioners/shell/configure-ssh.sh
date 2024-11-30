apt-get install -y openssh-server
systemctl start sshd
# get ip with hostname -I
ufw allow from 192.168.56.2/32 to any port 22 
# Allow default virtual box host ip
ufw allow from 10.0.2.2/32 to any port 22 
ufw --force enable
# Allow to Redis, Flask, and Postgres ports: ufw allow from 192.168.56.2/32 to any port 80
mkdir -p /home/ansible/.ssh
useradd -u 1010 -d /home/ansible -s /bin/bash ansible
chown ansible:ansible /home/ansible
usermod -aG sudo ansible
# TODO: install latest python
cat /vagrant/id_rsa.pub >> /home/ansible/.ssh/authorized_keys 
