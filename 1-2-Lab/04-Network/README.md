https://cloud.google.com/load-balancing/docs/network?hl=fr
https://cloud.google.com/compute/docs/instance-groups?hl=fr
https://cloud.google.com/load-balancing/docs/url-map-concepts?hl=fr
https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts?hl=fr

gcloud compute forwarding-rules describe www-rule --region us-east1

IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region us-east1 --format="json" | jq -r .IPAddress)

echo $IPADDRESS

while true; do curl -m1 $IPADDRESS; done