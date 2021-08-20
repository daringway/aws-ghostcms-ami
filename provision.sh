#!/bin/bash -x

# Install Guidelines from https://ghost.org/docs/install/ubuntu/
# Leverages https://pm2.keymetrics.io/docs/usage/pm2-doc-single-page/

# https://www.packer.io/docs/other/debugging.html#issues-installing-ubuntu-packages
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

INSTALL_DIR=/var/www/ghost-serverless
NODE_VERSION=14

if [[ $(id -u) != "0" ]]
then
  echo "ERROR: must run as root"
  exit 2
fi

# Copy rc.local
cp /tmp/rc.local /etc/rc.local
chmod +x /etc/rc.local

# Update Ubuntu
apt-get update
apt-get -y upgrade

# Add Repos
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

apt-get -y install jq fish unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install rest of needed software packages
curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt-get install -y yarn nginx nodejs
npm install ghost-cli@latest pm2@latest eslint ghost-static-site-generator -g

# change ubuntu to fish, yes really
chsh -s /usr/bin/fish ubuntu

# Install ghost
mkdir /var/www/ghost
chown -R ubuntu:ubuntu /var/www/ghost
cd /var/www/ghost
su ubuntu -c "ghost install local --no-start --no-enable"
rm -rf .ghost-cli .ghostpid config.deployment.json content current

###### Download ghost serverless ######
#git clone https://github.com/daringway/ghost-serverless $INSTALL_DIR
cp -R ghost-serverless $INSTALL_DIR
