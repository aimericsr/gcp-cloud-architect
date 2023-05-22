gcloud auth list
gcloud config list project

gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld

gcloud container images list

docker run -d -p 8080:8080 gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld

gcloud run deploy --image gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld --allow-unauthenticated --region=$LOCATION

gcloud container images delete gcr.io/$GOOGLE_CLOUD_PROJECT/helloworld

gcloud run services delete helloworld --region=us-central1