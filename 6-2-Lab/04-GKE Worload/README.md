gcloud container clusters create test-cluster --num-nodes=3  --enable-ip-alias

kubectl apply -f gb_frontend_pod.yaml
kubectl apply -f gb_frontend_cluster_ip.yaml
kubectl apply -f gb_frontend_ingress.yaml

When the ingress is created, an HTTP(S) load balancer is created along with an NEG (Network Endpoint Group) in each zone in which the cluster runs. After a few minutes, the ingress will be assigned an external IP.

The load balancer it created has a backend service running in your project that defines how Cloud Load Balancing distributes traffic. This backend service has a health status associated with it.


BACKEND_SERVICE=$(gcloud compute backend-services list | grep NAME | cut -d ' ' -f2)
gcloud compute backend-services get-health $BACKEND_SERVICE --global

kubectl get ingress gb-frontend-ingress

load testing : 
gsutil -m cp -r gs://spls/gsp769/locust-image .
gcloud builds submit \
    --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/locust-tasks:latest locust-image
gcloud container images list
gsutil cp gs://spls/gsp769/locust_deploy_v2.yaml .
sed 's/${GOOGLE_CLOUD_PROJECT}/'$GOOGLE_CLOUD_PROJECT'/g' locust_deploy_v2.yaml | kubectl apply -f -
kubectl get service locust-main

liveness prob : 
kubectl apply -f liveness-demo.yaml
kubectl describe pod liveness-demo-pod
kubectl exec liveness-demo-pod -- rm /tmp/alive (remove the file, so liveness should fail)
kubectl describe pod liveness-demo-pod

readiness prob(actually ready to send traffic) :
Unlike the liveness probe, an unhealthy readiness probe does not trigger the pod to restart.

kubectl apply -f readiness-demo.yaml
kubectl get service readiness-demo-svc
kubectl describe pod readiness-demo-pod

add file for readiness : 
kubectl exec readiness-demo-pod -- touch /tmp/healthz
kubectl describe pod readiness-demo-pod | grep ^Conditions -A 5

pod disruption budget : 
kubectl delete pod gb-frontend
kubectl apply -f gb_frontend_deployment.yaml

drain pods : 
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do
  kubectl drain --force --ignore-daemonsets --grace-period=10 "$node";
done

kubectl describe deployment gb-frontend | grep ^Replicas

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do
  kubectl uncordon "$node";
done

kubectl create poddisruptionbudget gb-pdb --selector run=gb-frontend --min-available 4

for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do
  kubectl drain --timeout=30s --ignore-daemonsets --grace-period=10 "$node";
done

kubectl describe deployment gb-frontend | grep ^Replicas