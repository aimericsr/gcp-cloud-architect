
gcloud container clusters get-credentials CLUSTER_NAME \
    --region=COMPUTE_REGION

kubectl version

kubectl create deploy hello-app --image=gcr.io/google-samples/hello-app:2.0

kubectl get pods

kubectl expose deployment hello-app --port 8082 --type LoadBalancer

kubectl get services

kubectl scale deployment hello-app --replicas 3


gcloud compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global