Naming is normally team-resource, e.g. an instance could be named kraken-webserver1.

unless directed, use n1-standard-1.

https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam

gcloud sql connect griffin-dev-db --user=wp_user --database=wordpress

gsutil -m cp -r gs://cloud-training/gsp321/wp-k8s .

gcloud container clusters get-credentials griffin-dev \
    --zone=us-east1-b

gcloud iam service-accounts keys create key.json \
    --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials \
    --from-file key.json
    
kubectl create -f wp-env.yaml
kubectl create -f wp-deployment.yaml
kubectl create -f wp-service.yaml