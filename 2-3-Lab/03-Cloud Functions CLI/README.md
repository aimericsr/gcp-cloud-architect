gcloud config set compute/region us-east4
mkdir gcf_hello_world
cd gcf_hello_world
nano index.js

gsutil mb -p [PROJECT_ID] gs://[BUCKET_NAME]

gcloud functions deploy helloWorld \
  --stage-bucket [BUCKET_NAME] \
  --trigger-topic hello_world \
  --runtime nodejs8

gcloud functions describe helloWorld

DATA=$(printf 'Hello World!'|base64) && gcloud functions call helloWorld --data '{"data":"'$DATA'"}'

gcloud functions logs read helloWorld