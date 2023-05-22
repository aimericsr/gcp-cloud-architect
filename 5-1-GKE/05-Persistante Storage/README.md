kubectl get persistentvolumeclaim
kubectl get persistentvolumeclaim

kubectl exec -it pvc-demo-pod -- sh
kubectl delete pod pvc-demo-pod

PVC does not create a PV, it create it when a Pod make a request

kubectl describe statefulset statefulset-demo
kubectl get pvc
kubectl describe pvc hello-web-disk-statefulset-demo-0


stateful set automatically restart pods
