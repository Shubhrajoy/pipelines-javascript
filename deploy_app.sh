#!/bin/bash

hname=$(hostname)
#curuser=$(whoami)
appfile=$(find /home/$1/azagent/azagent/_work/ -name server.js)
sudo curl -sL https://rpm.nodesource.com/setup_10.x | bash -
sudo yum install -y nodejs
sudo mkdir -p /var/www/html/sample

sudo yes|cp -f $appfile /var/www/html/sample
sudo sed -i '2d' /var/www/html/sample/server.js
sudo sed -i "2iconst hostname = '$hname';" /var/www/html/sample/server.js

sudo npm install -g pm2
sudo cd /var/www/html/sample
sudo pm2 start /var/www/html/sample/server.js --name="My Sample App"
sudo pm2 save
sudo pm2 startup

sudo echo "[nginx-stable]" > /etc/yum.repos.d/nginx.repo
sudo echo "name=nginx stable repo" >> /etc/yum.repos.d/nginx.repo
sudo echo "baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/" >> /etc/yum.repos.d/nginx.repo
sudo echo "gpgcheck=1" >> /etc/yum.repos.d/nginx.repo
sudo echo "enabled=1" >> /etc/yum.repos.d/nginx.repo
sudo echo "gpgkey=https://nginx.org/keys/nginx_signing.key" >> /etc/yum.repos.d/nginx.repo
sudo echo "module_hotfixes=true" >> /etc/yum.repos.d/nginx.repo

sudo yum install -y nginx
sudo systemctl enable nginx

sudo echo "server {" > /etc/nginx/conf.d/sample.conf
sudo echo "    listen 80;" >> /etc/nginx/conf.d/sample.conf
sudo echo "    server_name $hname;" >> /etc/nginx/conf.d/sample.conf
sudo echo "    location / {" >> /etc/nginx/conf.d/sample.conf
sudo echo "        proxy_pass http://$hname:5000;" >> /etc/nginx/conf.d/sample.conf
sudo echo "        proxy_http_version 1.1;" >> /etc/nginx/conf.d/sample.conf
sudo echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/sample.conf
sudo echo "        proxy_set_header Connection 'upgrade';" >> /etc/nginx/conf.d/sample.conf
sudo echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/sample.conf
sudo echo "        proxy_cache_bypass \$http_upgrade;" >> /etc/nginx/conf.d/sample.conf
sudo echo "    }" >> /etc/nginx/conf.d/sample.conf
sudo echo "}" >> /etc/nginx/conf.d/sample.conf

sudo pm2 restart all
sudo cat /var/log/audit/audit.log | grep nginx | grep denied | audit2allow -M mynginx
sudo semodule -i mynginx.pp
sudo systemctl restart nginx