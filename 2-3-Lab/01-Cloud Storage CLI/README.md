gcloud config set compute/region us-west1

gsutil mb gs://YOUR-BUCKET-NAME

curl https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg
gsutil cp ada.jpg gs://YOUR-BUCKET-NAME
rm ada.jpg

gsutil cp -r gs://YOUR-BUCKET-NAME/ada.jpg .

gsutil cp gs://YOUR-BUCKET-NAME/ada.jpg gs://YOUR-BUCKET-NAME/image-folder/

gsutil ls gs://YOUR-BUCKET-NAME
gsutil ls -l gs://YOUR-BUCKET-NAME/ada.jpg

gsutil acl ch -u AllUsers:R gs://YOUR-BUCKET-NAME/ada.jpg

gsutil acl ch -d AllUsers gs://YOUR-BUCKET-NAME/ada.jpg

gsutil rm gs://YOUR-BUCKET-NAME/ada.jpg