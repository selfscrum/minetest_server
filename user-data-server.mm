Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
users:
    - name: desixma
      groups: users, admin
      sudo: ALL=(ALL) NOPASSWD:ALL
      shell: /bin/bash
      ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH6orvm7dzkp47YBEvxOk3cvvYR5io32OmbbnR96bGjlT7LZleL4oV/aozCAG4Axy6mgByULUsxG9l/JhmFa3zg0/rP9HrklX7oPNdAdN26QAquD6dgaZ3PFP7UXkkNaTTAmJcw02EaCNuCcGLGinKOi0LETN/K+BTfpL7Q5kUbWFnkDjJpiIjqZwNzBqU3G7OfbqpW+EbcCAouBkT+rE09lAUth5BXWgq7MhtF8LrfnIrrf0demkXqqYm2clXd5266M2LgCsu/LayMkO0ig4SH7DotgXxNeXLJQtu7E02rrxFTZuNvazQQ7TwBbZdDELmYB8BdRmTQjYZqMSw6zaf
packages:
    - fail2ban
    - ufw
package_update: true
package_upgrade: true
runcmd:
#    - printf "[sshd]\nenabled = true\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
#    - systemctl enable fail2ban
    - ufw allow OpenSSH
    - ufw enable
    - sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
    - sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
    - sed -i -e '/^X11Forwarding/s/^.*$/X11Forwarding no/' /etc/ssh/sshd_config
    - sed -i -e '/^#MaxAuthTries/s/^.*$/MaxAuthTries 2/' /etc/ssh/sshd_config
    - sed -i -e '/^#AllowTcpForwarding/s/^.*$/AllowTcpForwarding no/' /etc/ssh/sshd_config
    - sed -i -e '/^#AllowAgentForwarding/s/^.*$/AllowAgentForwarding no/' /etc/ssh/sshd_config
    - sed -i -e '/^#AuthorizedKeysFile/s/^.*$/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config
    - sed -i '$a AllowUsers desixma' /etc/ssh/sshd_config
    - sleep 5
#    - apt update -y
#    - apt install hcloud-cli

cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"
#!/bin/bash

# prepare host for container
apt -y update
apt -y install docker.io
apt -y install unzip
useradd -m minetest
usermod -L minetest

# allow external access
ufw allow 30000/udp
ufw allow 30000/tcp
ufw reload

# create host dir for configuration
mkdir -p /home/minetest/conf
chown 30000:30000 /home/minetest/conf
touch /home/minetest/conf/minetest.conf
echo "active_block_range = 3" > /home/minetest/conf/minetest.conf
echo "max_block_send_distance = 30" >> /home/minetest/conf/minetest.conf
echo "max_block_generate_distance = 30" >> /home/minetest/conf/minetest.conf
echo "client_unload_unused_data_timeout = 300" >> /home/minetest/conf/minetest.conf
echo "client_mapblock_limit = 2000" >> /home/minetest/conf/minetest.conf
echo "time_speed = 0" >> /home/minetest/conf/minetest.conf
chown 30000:30000 /home/minetest/conf/minetest.conf

# create host dir for worlds, mods etc.
mkdir -p /home/minetest/data/.minetest/mods
chown -R 30000:30000 /home/minetest/data

# create server
docker run -p "30000:30000/udp" -e "PGID=30000" -e "PUID=30000"  -v /home/minetest/data/:/var/lib/minetest/ -v /home/minetest/conf:/etc/minetest/ registry.gitlab.com/minetest/minetest/server:025035db5c87e9eaa9f83859f860539fc4fb4dc0 &
sleep 5
docker stop $(docker ps -q)

# install inventory mod
wget https://github.com/minetest-mods/unified_inventory/archive/master.zip
unzip master.zip
rm master.zip
mv unified_inventory-master /home/minetest/data/.minetest/mods/unified_inventory
chown -R 30000:30000 /home/minetest/data/.minetest/mods/unified_inventory
echo "load_mod_unified_inventory = true" >> /home/minetest/data/.minetest/worlds/world/world.mt
# restart server
docker run -p "30000:30000/udp" -e "PGID=30000" -e "PUID=30000"  -v /home/minetest/data/:/var/lib/minetest/ -v /home/minetest/conf:/etc/minetest/ $(docker image ls -q)

# install mesecons mod
wget https://github.com/minetest-mods/mesecons/archive/master.zip
unzip master.zip
rm master.zip
mv mesecons-master /home/minetest/data/.minetest/mods/mesecons
chown -R 30000:30000 /home/minetest/data/.minetest/mods/mesecons
echo "load_mod_mesecons = true" >> /home/minetest/data/.minetest/worlds/world/world.mt
# restart server
docker run -p "30000:30000/udp" -e "PGID=30000" -e "PUID=30000"  -v /home/minetest/data/:/var/lib/minetest/ -v /home/minetest/conf:/etc/minetest/ $(docker image ls -q)
--//
