gcloud config set compute/zone us-central1-b
gcloud container clusters create io
gcloud container clusters get-credentials io

gsutil cp -r gs://spls/gsp021/* .
cd orchestrate-with-kubernetes/kubernetes
ls

kubectl create deployment nginx --image=nginx:1.10.0
kubectl get pods
kubectl expose deployment nginx --port 80 --type LoadBalancer (Behind the scenes Kubernetes created an external IP address)
kubectl get services

pods : 
cd ~/orchestrate-with-kubernetes/kubernetes
kubectl create -f pods/monolith.yaml
kubectl get pods
kubectl describe pods monolith

interacting with pods : 
kubectl port-forward monolith 10080:80
curl http://127.0.0.1:10080
curl http://127.0.0.1:10080/secure
curl -u user http://127.0.0.1:10080/login
TOKEN=$(curl http://127.0.0.1:10080/login -u user|jq -r '.token')
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:10080/secure

kubectl logs monolith
kubectl logs -f monolith
kubectl exec monolith --stdin --tty -c monolith -- /bin/sh
ping -c 3 google.com

service :
cat pods/secure-monolith.yaml
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf
kubectl create -f pods/secure-monolith.yaml

cat services/monolith.yaml
kubectl create -f services/monolith.yaml

gcloud compute firewall-rules create allow-monolith-nodeport \
  --allow=tcp:31000

gcloud compute instances list
curl -k https://<EXTERNAL_IP>:31000

kubectl get services monolith
kubectl describe services monolith

add labels : 
kubectl get pods -l "app=monolith"
kubectl get pods -l "app=monolith,secure=enabled"

kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels

kubectl describe services monolith | grep Endpoints

gcloud compute instances list (grab nodes ip because the type of the service is NodePort)
curl -k https://<EXTERNAL_IP>:31000

deployments : 
cat deployments/auth.yaml

kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml

kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

kubectl get services frontend
curl -k https://<EXTERNAL-IP>