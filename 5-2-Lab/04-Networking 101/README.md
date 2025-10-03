An internal fully qualified domain name (FQDN) for an instance looks like this: hostName.[ZONE].c.[PROJECT_ID].internal .

performance testing / traceroute : 
sudo apt-get update
sudo apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege

traceroute www.icann.org
traceroute europe-test-01.europe-west1-b


performance testing / iperf : 
VM1 : 
sudo apt-get update
sudo apt-get -y install traceroute mtr tcpdump iperf whois host dnsutils siege

VM2 : 
iperf -s #run in server mode

VM1 : 
iperf -c us-test-01.us-central1-a #run in client mode, connection to eu1-vm


iperf -c europe-test-01.europe-west1-b -u -b 2G #iperf client side - send 2 Gbits/s
iperf -c us-test-01.us-central1-a -P 20

source : 
https://www.amazon.com/TCP-Ip-Illustrated-Volume-Protocols/dp/9332535957/ref=dp_ob_title_bk
https://github.com/eeertekin/bbcp