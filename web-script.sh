sudo su
sudo yum install nginx -y
sudo systemctl start nginx -y
sudo systemctl enable nginx -y
sudo echo "Welcome to Nginx Azim" > /var/www/html/index.html
sudo systemctl restart nginx -y