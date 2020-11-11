#!/bin/bash -x

sudo mv /tmp/rc.local /etc/rc.local
chmod +x /etc/rc.local

mkdir /var/www
cd /var/www

git clone --single-branch https://github.com/daringway/aws-ec2-cli-tools.git
bash ./aws-ec2-cli-tools/setup.sh

mv /tmp/templates /var/www
mv /tmp/manager   /var/www

# Add yarn repo
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

######Download and install Packages######
sudo apt-get update
sudo apt-get upgrade

curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt-get install -y ec2-instance-connect nodejs zip nginx yarn jq fish
sudo snap install --classic aws-cli
sudo snap install --classic certbot

sudo ln -s /snap/bin/certbot /usr/bin/certbot

# install ghost
sudo npm install ghost-cli@latest eslint ghost-static-site-generator -g

# Setup firewall
sudo ufw allow 'Nginx Full'

# Install ghost publisher
sudo npm install pm2@latest -g
pm2 startup systemd

for DIR in /var/www/manager/publisher /var/www/manager/starter
do
  cd $DIR
  npm install
  pm2 start $DIR
done
sudo pm2 startup

######Download and install Ghost######
sudo mkdir -p /var/www/ghost
sudo chown -R ubuntu:ubuntu /var/www /home/ubuntu
sudo chmod 775 /var/www/ghost
cd /var/www/ghost
ghost install local
ghost setup linux-user systemd
sudo rm -r /var/www/ghost/config.development.json /var/www/ghost/content /var/www/ghost/current


# TODO run ghost install
# TODO configure ghost for mailgun https://ghost.org/docs/concepts/config/#setup-an-email-sending-account

# TODO update hostname
# TODO update nginx upload limit

exit 0
