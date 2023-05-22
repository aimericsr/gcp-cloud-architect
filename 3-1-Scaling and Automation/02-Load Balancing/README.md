sudo apt-get update
sudo apt-get install -y apache2
sudo service apache2 start
curl localhost
sudo update-rc.d apache2 enable
sudo service apache2 status


stress test : 
export LB_IP=<Enter your [LB_IP_v4] here>
echo $LB_IP
ab -n 500000 -c 1000 http://$LB_IP/


https://gmusumeci.medium.com/getting-started-with-terraform-and-google-cloud-platform-gcp-deploying-vms-in-a-private-only-f9ab61fa7d15

