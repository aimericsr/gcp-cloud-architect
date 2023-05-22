
gcloud container clusters get-credentials CLUSTER_NAME \
    --region=COMPUTE_REGION

kubectl version
kubectl create deploy nginx --image=nginx:1.17.10
kubectl get pods
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl get services
kubectl scale deployment nginx --replicas 3
kubectl get pods
kubectl get services