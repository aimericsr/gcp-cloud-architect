gcloud compute instances create gcelab --project=qwiklabs-gcp-01-1b5ba1ad700a --zone=us-west1-a --machine-type=e2-medium --network-interface=network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=753504212944-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=gcelab,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230411,mode=rw,size=10,type=projects/qwiklabs-gcp-01-1b5ba1ad700a/zones/us-west1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=ec-src=vm_add-gcloud --reservation-affinity=any


gcloud auth list
gcloud config list project

sudo apt-get update
sudo apt-get install -y nginx
ps auwx | grep nginx


gcloud compute instances create gcelab2 --machine-type e2-medium --zone us-west1-a
gcloud compute instances create --help

gcloud config set compute/zone ...
gcloud config set compute/region ...

gcloud compute ssh gcelab2 --zone us-west1-a (no passphrase required)