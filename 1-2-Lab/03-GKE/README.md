gcloud auth list
gcloud config list project

gcloud config set compute/region us-west1
gcloud config set compute/zone us-west1-c

gcloud container clusters create --machine-type=e2-medium --zone=us-west1-c lab-cluster 

gcloud container clusters get-credentials lab-cluster 
cat .kube/config

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
// create a http load balancer to expose the service with a public IP 
kubectl expose deployment hello-server --type=LoadBalancer --port 8080
watch kubectl get service