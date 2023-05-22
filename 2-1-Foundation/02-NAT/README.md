https://cloud.google.com/nat/docs/overview?hl=fr
https://cloud.google.com/iap/docs/using-tcp-forwarding?hl=fr
https://cloud.google.com/blog/products/identity-security/cloud-iap-enables-context-aware-access-to-vms-via-ssh-and-rdp-without-bastion-hosts?hl=en
https://www.cloudskillsboost.google/course_sessions/2822144/labs/374994

gcloud compute ssh vm-internal --zone us-central1-c --tunnel-through-iap
ping -c 2 www.google.com
exit

gsutil cp gs://cloud-training/gcpnet/private/access.svg gs://$MY_BUCKET
gsutil cp gs://$MY_BUCKET/*.svg .

gcloud compute ssh vm-internal --zone us-central1-c --tunnel-through-iap

sudo apt-get update