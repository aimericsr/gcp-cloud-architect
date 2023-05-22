gcloud container clusters get-credentials standard-cluster-1 \
    --zone=us-central1-a

kubectl apply -f deployment.yaml