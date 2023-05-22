
create bucket : 
export LOCATION=EU
export DEVSHELL_PROJECT_ID=qwiklabs-gcp-04-504c678dbc64

gsutil mb -l $LOCATION gs://$DEVSHELL_PROJECT_ID

copy file from public cloud storage : 
gsutil cp gs://cloud-training/gcpfci/my-excellent-blog.png my-excellent-blog.png

gsutil cp my-excellent-blog.png gs://$DEVSHELL_PROJECT_ID/my-excellent-blog.png

gsutil acl ch -u allUsers:R gs://$DEVSHELL_PROJECT_ID/my-excellent-blog.png



gcloud compute instances create bloghost-1 --project=qwiklabs-gcp-04-504c678dbc64 --zone=us-west1-a --machine-type=e2-medium --network-interface=network-tier=PREMIUM,subnet=default --metadata=startup-script=apt-get\ update$'\n'apt-get\ install\ apache2\ php\ php-mysql\ -y$'\n'service\ apache2\ restart,enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=115634455385-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=bloghost,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230411,mode=rw,size=10,type=projects/qwiklabs-gcp-04-504c678dbc64/zones/us-west1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=ec-src=vm_add-gcloud --reservation-affinity=any