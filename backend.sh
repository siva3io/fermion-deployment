#!/bin/bash
echo "Welcome!!"
echo "LET ME FIRST UPDATE YOUR SYSTEM"
sudo apt update
echo " Is your ssh key added to the git and is 3031 port open for your new instance ?? 'y' for yes or 'n' for no " 
read ans
echo " Input your domain name ! "
read WEBSITE_NAME
if [ $ans == "y" ]
then
   echo " Should I install NGINX for you ? 'y' for yes or 'n' for no "
   read NGINX
   if [ $NGINX == "y" ]
   then
       sudo apt install nginx
   fi
   wget --no-check-certificate --no-proxy 'https://bash-nginx-configuration.s3.ap-south-1.amazonaws.com/backend_nginx_settings'
   sed -i 's/WEB_NAME/'$WEBSITE_NAME'/g' backend_nginx_settings
   sudo mv /home/ubuntu/backend_nginx_settings /etc/nginx/sites-enabled
   sudo chmod 777 /etc/nginx/sites-enabled
   sudo service nginx reload
   echo " Do you want SSL ? We use certbot for the same !! "
   read SSL
   if [ $SSL == "y" ]
   then
       sudo apt install letsencrypt
       sleep 1
       netstat -plant
       sudo systemctl status certbot.timer
       sudo pkill -f nginx & wait $!
       sudo certbot certonly --standalone --agree-tos --preferred-challenges http -d $WEBSITE_NAME 
       sudo apt install python3-certbot-nginx
       sudo certbot --nginx --agree-tos --preferred-challenges http -d $WEBSITE_NAME 
       sudo pkill -f nginx & wait $!
       sudo service nginx start
       sudo service nginx status
   fi
   echo "Do you want me to install node and npm ? 'y' or 'n'  "
   read nodenpm
   if [ $nodenpm == "y" ]
   then
       sudo apt install nodejs
       echo " your node version is $(node -v)"
       sudo apt install npm
   fi
   echo "Do you want me to install pm2 ? 'y' or 'n' "
   read pm
   if [ $pm == "y" ]
   then
       sudo npm i -g pm2
   fi
   echo "Do you want me to install golang ? 'y' or 'n' "
   read golang
   if [ $golang == "y" ]
   then
       sudo apt install golang-go
       echo "your golang version is $(go version)"
   fi
   echo "Cloning code_develop_go_0.0"
   git clone git@bitbucket.org:eunimart_v2/code_develop_go_0.0.git
   
   sleep 3
   cd /home/ubuntu/$service/docs
   sed -i 's/"https"/"http"/g' docs.go
   sed -i 's/dev-api.eunimart.com/'$WEBSITE_NAME'/g' docs.go
   echo "Installing postgresql !"
   sudo apt install postgresql postgresql-contrib
   sudo systemctl start postgresql.service
   echo "This is the status of postgresql : "
   sudo systemctl status postgresql.service
   cd ..
   sudo chmod 777 -R ubuntu
   cd /home/ubuntu
   sudo -u postgres psql<<-EOF
   CREATE USER eunimartuser WITH SUPERUSER PASSWORD 'eunimart' ;
   CREATE DATABASE euni_plt_go;
   grant all privileges on database euni_plt_go to eunimartuser;
EOF
   cd /home/ubuntu/code_develop_go_0.0
   go run . -clearDB=true -migrateDB=true -seedMD=true -seedTD=true;
else
   echo "Sorry I can not work without that !!"
fi