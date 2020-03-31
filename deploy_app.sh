#!/bin/bash

hname=$(hostname)
#curuser=$(whoami)
appfile=$(find /home/$1/azagent/azagent/_work/ -name server.js)
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
yum install -y nodejs
mkdir -p /var/www/html/sample

yes|cp -f $appfile /var/www/html/sample
sed -i '2d' /var/www/html/sample/server.js
sed -i "2iconst hostname = '$hname';" /var/www/html/sample/server.js

npm install -g pm2
cd /var/www/html/sample
pm2 start /var/www/html/sample/server.js --name="My Sample App"
pm2 save
pm2 startup

echo "[nginx-stable]" > /etc/yum.repos.d/nginx.repo
echo "name=nginx stable repo" >> /etc/yum.repos.d/nginx.repo
echo "baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/" >> /etc/yum.repos.d/nginx.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/nginx.repo
echo "enabled=1" >> /etc/yum.repos.d/nginx.repo
echo "gpgkey=https://nginx.org/keys/nginx_signing.key" >> /etc/yum.repos.d/nginx.repo
echo "module_hotfixes=true" >> /etc/yum.repos.d/nginx.repo

yum install -y nginx
systemctl enable nginx

echo "server {" > /etc/nginx/conf.d/sample.conf
echo "    listen 80;" >> /etc/nginx/conf.d/sample.conf
echo "    server_name $hname;" >> /etc/nginx/conf.d/sample.conf
echo "    location / {" >> /etc/nginx/conf.d/sample.conf
echo "        proxy_pass http://$hname:5000;" >> /etc/nginx/conf.d/sample.conf
echo "        proxy_http_version 1.1;" >> /etc/nginx/conf.d/sample.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/sample.conf
echo "        proxy_set_header Connection 'upgrade';" >> /etc/nginx/conf.d/sample.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/sample.conf
echo "        proxy_cache_bypass \$http_upgrade;" >> /etc/nginx/conf.d/sample.conf
echo "    }" >> /etc/nginx/conf.d/sample.conf
echo "}" >> /etc/nginx/conf.d/sample.conf

pm2 restart all
cat /var/log/audit/audit.log | grep nginx | grep denied | audit2allow -M mynginx
semodule -i mynginx.pp
systemctl restart nginx