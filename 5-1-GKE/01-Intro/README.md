gcloud compute instances create $MY_VMNAME \
--machine-type "e2-standard-2" \
--image-project "debian-cloud" \
--image-family "debian-11" \
--subnet "default"

gcloud iam service-accounts create test-service-account2 --display-name "test-service-account2"

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member serviceAccount:test-service-account2@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role roles/viewer

gsutil cp gs://cloud-training/ak8s/cat.jpg cat.jpg
gsutil cp cat.jpg gs://$MY_BUCKET_NAME_1

gsutil acl get gs://$MY_BUCKET_NAME_1/cat.jpg  > acl.txt
cat acl.txt
gsutil acl set private gs://$MY_BUCKET_NAME_1/cat.jpg

gcloud auth activate-service-account --key-file credentials.json
gcloud config list
gsutil cp gs://$MY_BUCKET_NAME_1/cat.jpg ./cat-copy.jpg

gsutil iam ch allUsers:objectViewer gs://$MY_BUCKET_NAME_1

gcloud compute scp index.html first-vm:index.nginx-debian.html --zone=us-central1-c