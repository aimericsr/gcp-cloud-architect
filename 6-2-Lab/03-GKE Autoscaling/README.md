gcloud container clusters create scaling-demo --num-nodes=3 --enable-vertical-pod-autoscaling

kubectl apply -f php-apache.yaml
kubectl get deployment
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10 (maintain 50% CPU usage across all pods)
kubectl get hpa

gcloud container clusters describe scaling-demo | grep ^verticalPodAutoscaling -A 1 (gcloud container clusters update scaling-demo --enable-vertical-pod-autoscaling)

test VPA : 
kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:1.0
kubectl get deployment hello-server
kubectl set resources deployment hello-server --requests=cpu=450m
kubectl describe pod hello-server | sed -n "/Containers:$/,/Conditions:/p"

A VPA can have one of three different update policies which can be useful depending on your application:

Off: this policy means VPA will generate recommendations based on historical data which you can manually apply.
Initial: VPA recommendations will be used to create new pods once and then won't change the pod size after.
Auto: pods will regularly be deleted and recreated to match the size of the recommendations.

kubectl apply -f hello-vpa.yaml
kubectl describe vpa hello-server-vpa

set VPA mode to auto : 
sed -i 's/Off/Auto/g' hello-vpa.yaml
kubectl apply -f hello-vpa.yaml
kubectl scale deployment hello-server --replicas=2

cluster autoscaler (nodes) :
gcloud beta container clusters update scaling-demo --enable-autoscaling --min-nodes 1 --max-nodes 5
gcloud beta container clusters update scaling-demo \
--autoscaling-profile optimize-utilization
kubectl get deployment -n kube-system

create pod disruption for kube-system pods : 
kubectl create poddisruptionbudget kube-dns-pdb --namespace=kube-system --selector k8s-app=kube-dns --max-unavailable 1
kubectl create poddisruptionbudget prometheus-pdb --namespace=kube-system --selector k8s-app=prometheus-to-sd --max-unavailable 1
kubectl create poddisruptionbudget kube-proxy-pdb --namespace=kube-system --selector component=kube-proxy --max-unavailable 1
kubectl create poddisruptionbudget metrics-agent-pdb --namespace=kube-system --selector k8s-app=gke-metrics-agent --max-unavailable 1
kubectl create poddisruptionbudget metrics-server-pdb --namespace=kube-system --selector k8s-app=metrics-server --max-unavailable 1
kubectl create poddisruptionbudget fluentd-pdb --namespace=kube-system --selector k8s-app=fluentd-gke --max-unavailable 1
kubectl create poddisruptionbudget backend-pdb --namespace=kube-system --selector k8s-app=glbc --max-unavailable 1
kubectl create poddisruptionbudget kube-dns-autoscaler-pdb --namespace=kube-system --selector k8s-app=kube-dns-autoscaler --max-unavailable 1
kubectl create poddisruptionbudget stackdriver-pdb --namespace=kube-system --selector app=stackdriver-metadata-agent --max-unavailable 1
kubectl create poddisruptionbudget event-pdb --namespace=kube-system --selector k8s-app=event-exporter --max-unavailable 1

kubectl get nodes


node auto-provisioning : 
gcloud container clusters update scaling-demo \
    --enable-autoprovisioning \
    --min-cpu 1 \
    --min-memory 2 \
    --max-cpu 45 \
    --max-memory 160


test with larger demande : 
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

kubectl get hpa
kubectl get deployment php-apache

using paused pods : 
kubectl apply -f pause-pod.yaml