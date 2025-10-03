gcloud beta container --project "qwiklabs-gcp-03-536657dda061" clusters create "onlineboutique-cluster-436" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.26.3-gke.1000" --release-channel "rapid" --machine-type "n1-standard-2" --image-type "COS_CONTAINERD" --disk-type "pd-balanced" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/qwiklabs-gcp-03-536657dda061/global/networks/default" --subnetwork "projects/qwiklabs-gcp-03-536657dda061/regions/us-central1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "us-central1-c"


gcloud container clusters get-credentials onlineboutique-cluster-436 \
    --zone=us-central1-c

kubectl apply -f namespaces.yaml

git clone https://github.com/GoogleCloudPlatform/microservices-demo.git &&
cd microservices-demo && kubectl apply -f ./release/kubernetes-manifests.yaml --namespace dev


move applications to new node pool  :

no new pods can be created on this node pool : 
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=default-pool -o=name); do
  kubectl drain --force --ignore-daemonsets --grace-period=10 --delete-emptydir-data "$node";
done

kubectl apply -f onlineboutique-frontend-pdb.yaml

gcr.io/qwiklabs-resources/onlineboutique-frontend:v2.1