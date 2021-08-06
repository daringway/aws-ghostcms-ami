#!/bin/bash -x

# Install Guidelines from https://ghost.org/docs/install/ubuntu/
# Leverages https://pm2.keymetrics.io/docs/usage/pm2-doc-single-page/

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

# Add Repos
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Update Ubuntu
apt-get update
apt-get -y upgrade

apt-get install -y jq fish unzip

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install rest of needed software packages
curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt-get install -y yarn nginx nodejs
npm install ghost-cli@latest pm2@latest eslint ghost-static-site-generator -g

# change ubuntu to fish, yes really
chsh -s /usr/bin/fish ubuntu

###### Download ghost serverless ######
git clone https://github.com/daringway/ghost-serverless $INSTALL_DIR
