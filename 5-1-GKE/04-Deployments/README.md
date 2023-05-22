source <(kubectl completion bash)
gcloud container clusters get-credentials standard-cluster-1 \
    --zone=us-central1-a
git clone https://github.com/GoogleCloudPlatform/training-data-analyst

kubectl apply -f ./nginx-deployment.yaml
kubectl get deployments

kubectl scale --replicas=3 deployment nginx-deployment

A deployment's rollout is triggered if and only if the deployment's Pod template (that is, .spec.template) is changed, for example, if the labels or container images of the template are updated. Other updates, such as scaling the deployment, do not trigger a rollout.

kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1 --record
kubectl rollout status deployment.v1.apps/nginx-deployment
kubectl rollout history deployment nginx-deployment


kubectl rollout undo deployments [NAME_DEPLOYMENT]
kubectl rollout history deployment [NAME_DEPLOYMENT]
kubectl rollout history deployment/[NAME_DEPLOYMENT] --revision=3

watch kubectl get service nginx