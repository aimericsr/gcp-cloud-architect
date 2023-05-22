https://cloud.google.com/network-connectivity/docs/vpn/how-to/automate-vpn-setup-with-terraform?hl=fr

HA VPN requires dynamic routing to enable 99.99% availability

gcloud compute networks describe vpc-demo
gcloud compute networks update vpc-demo --bgp-routing-mode GLOBAL