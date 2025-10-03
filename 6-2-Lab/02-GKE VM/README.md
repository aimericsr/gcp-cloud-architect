gcloud container clusters get-credentials hello-demo-cluster --zone us-central1-a

kubectl scale deployment hello-server --replicas=2

gcloud container clusters resize hello-demo-cluster --node-pool node \
    --num-nodes 3 --zone us-central1-a

gcloud container node-pools create larger-pool \
  --cluster=hello-demo-cluster \
  --machine-type=e2-standard-2 \
  --num-nodes=1 \
  --zone=us-central1-a

set the old node pool to unscheduable : 
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=node -o=name); do
  kubectl cordon "$node";
done

move the container to the other node pool : 
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=node -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-local-data --grace-period=10 "$node";
done

kubectl get pods -o=wide

delete the old node pool : 
gcloud container node-pools delete node --cluster hello-demo-cluster --zone us-central1-a

multi-zonal vs regional clusters : 

Note: A multi-zonal cluster has at least one additional zone defined but only has a single replica of the control plane running in a single zone. Workloads can still run during an outage of the control plane's zone, but no configurations can be made to the cluster until the control plane is available.
A regional cluster has multiple replicas of the control plane, running in multiple zones within a given region. Nodes also run in each zone where a replica of the control plane runs. Regional clusters consume the most resources but offer the best availability.

gcloud container clusters create regional-demo --region=us-central1 --num-nodes=1

lunch two pods on different nodes : 
kubectl apply -f pod-1.yaml
kubectl apply -f pod-2.yaml (NodeAffinity / PodAffinity)

kubectl get pod pod-1 pod-2 --output wide

simulate traffic : 
kubectl exec -it pod-1 -- sh
ping [POD-2-IP]

SELECT 
    jsonPayload.src_instance.zone AS src_zone, jsonPayload.src_instance.vm_name AS src_vm, jsonPayload.dest_instance.zone AS dest_zone, jsonPayload.dest_instance.vm_name 
FROM `qwiklabs-gcp-03-48d9239dcd57.us_central_flow_logs.compute_googleapis_com_vpc_flows_20230526` 
LIMIT 1000

move pods to the same zone : 
sed -i 's/podAntiAffinity/podAffinity/g' pod-2.yaml
kubectl delete pod pod-2
kubectl create -f pod-2.yaml
kubectl get pod pod-1 pod-2 --output wide

https://cloud.google.com/vpc/network-pricing?hl=fr