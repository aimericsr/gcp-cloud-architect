gcloud --version
gcloud auth login
gcloud compute instances create lab-1
gcloud config list
gcloud compute zones list
gcloud config set compute/zone ZONE

gcloud init --no-launch-browser

gcloud compute instances list

gcloud config configurations activate default

gcloud iam roles list | grep "name:"
gcloud iam roles describe roles/compute.instanceAdmin

gcloud config configurations activate user2
