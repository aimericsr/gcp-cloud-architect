https://cloud.google.com/vpc/docs/create-use-multiple-interfaces?hl=fr

sudo ifconfig

ping with adresse insted of IP : 
ping -c 3 <vm_name>
work only if the target VM has the nic0 interface in the same network as the VM you lunch this command

if can't ping the eu-west1-a vm from my us-east1-c vm : 

Note: This does not work! In a multiple interface instance, every interface gets a route for the subnet that it is in. In addition, the instance gets a single default route that is associated with the primary interface eth0. Unless manually configured otherwise, any traffic leaving an instance for any destination other than a directly connected subnet will leave the instance via the default route on eth0.
If you run : ip route, you can't find the ip range for the subnet in europe, only the subnet in the US, that's why you can't ping the EU vm