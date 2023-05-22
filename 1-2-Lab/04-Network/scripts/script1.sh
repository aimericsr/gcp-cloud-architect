apt-get update  
apt-get install apache2 php php-mysql -y
service apache2 restart
echo "
<h3>Web Server: www1</h3>" | tee /var/www/html/index.html'