gsutil -m cp -r gs://spls/gsp766/gke-qwiklab .

Create namespaces : 
kubectl get namespace
kubectl api-resources --namespaced=true
kubectl get services --namespace=kube-system

kubectl create namespace team-a && \
kubectl create namespace team-b

kubectl run app-server --image=centos --namespace=team-a -- sleep infinity && \
kubectl run app-server --image=centos --namespace=team-b -- sleep infinity

kubectl get pods -A
kubectl describe pod app-server --namespace=team-a

kubectl config set-context --current --namespace=team-a

IAM : 
IAM vs RBAC : There are several roles that can be assigned to users and service accounts in IAM that govern their level of access with GKE. RBAC's granular permissions build on the access already provided by IAM and cannot restrict access granted by it. As a result, for multi-tenant namespaced clusters, the assigned IAM role should grant minimal access.

add cluster viewer role to team-a service account : 
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
--member=serviceAccount:team-a-dev@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com  \
--role=roles/container.clusterViewer

RBAC : 
role or clusterole. Role can be scoped to a namespace

create role via cli : kubectl create role pod-reader \
--resource=pods --verb=watch --verb=get --verb=list

create RBAC role via yaml file : 
kubectl create -f developer-role.yaml

Bind that role to the IAM role : 
kubectl create rolebinding team-a-developers \
--role=developer --user=team-a-dev@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

Test the permissions : 
gcloud iam service-accounts keys create /tmp/key.json --iam-account team-a-dev@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

gcloud auth activate-service-account  --key-file=/tmp/key.json

gcloud container clusters get-credentials multi-tenant-cluster --zone us-central1-a --project ${GOOGLE_CLOUD_PROJECT}

Create Quota : 
Limit the numbers of ressources (pods)
kubectl create quota test-quota \
--hard=count/pods=2,count/services.loadbalancers=1 --namespace=team-a

kubectl describe quota test-quota --namespace=team-a

export KUBE_EDITOR="nano"
kubectl edit quota test-quota --namespace=team-a

Limit the usage of ressources (CPU, RAM):
At the namespace level : 
kubectl create -f cpu-mem-quota.yaml
At the pod level : 
kubectl create -f cpu-mem-demo-pod.yaml --namespace=team-a
kubectl describe quota cpu-mem-quota --namespace=team-a

enable GKE usage monitoring : 
gcloud container clusters \
update multi-tenant-cluster --zone us-central1-a \
--resource-usage-bigquery-dataset cluster_dataset