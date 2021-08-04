#!/bin/bash -x

# Install Guidelines from https://ghost.org/docs/install/ubuntu/
# Leverages https://pm2.keymetrics.io/docs/usage/pm2-doc-single-page/

INSTALL_DIR=/var/www/ghost-serverless
NODE_VERSION=14

mkdir /var/www

git clone --single-branch https://github.com/daringway/ghost-serverless $INSTALL_DIR
bash /var/www/ghost-serverless/setup.sh

mv /tmp/templates /var/www

# Add repos
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

######Download and install Packages######
sudo apt-get update
sudo apt-get upgrade

curl -sL https://deb.nodesource.com/setup+${NODE_VERSION}.x | sudo bash -
sudo apt-get install -y ec2-instance-connect nodejs zip nginx yarn jq fish unzip
#sudo snap install --classic aws-cli

# Install aws cli v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# change ubuntu to fish, yes really
sudo chsh -s /usr/bin/fish ubuntu

# install ghost
sudo npm install ghost-cli@latest pm2@latest eslint ghost-static-site-generator -g

# Setup firewall
sudo ufw allow 'Nginx Full'

for DIR in $(ls -d $INSTALL_DIR/services/*)
do
  (cd $DIR; sudo npm install)
done

######Download and install Ghost######
sudo mkdir -p /var/www/ghost
sudo chown -R ubuntu:ubuntu /var/www /home/ubuntu $INSTALL_DIR
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
