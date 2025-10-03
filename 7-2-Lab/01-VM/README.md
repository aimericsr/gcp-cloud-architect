
WARNING : Not Working with TF

gcloud services enable compute.googleapis.com

gsutil mb gs://fancy-store-$DEVSHELL_PROJECT_ID

git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
nvm install --lts
cd microservices
npm start

gsutil cp ~/monolith-to-microservices/startup-script.sh gs://fancy-store-$DEVSHELL_PROJECT_ID

cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

redeploy : 
cd ~/monolith-to-microservices/react-app
npm install && npm run-script build

cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/


update IP in the .env file (redeploy code) : 

cd ~/monolith-to-microservices/react-app/
cd ~/monolith-to-microservices/react-app
npm install && npm run-script build
cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

update frontend MIG (to pull new code with the startup script):
gcloud compute instance-groups managed rolling-action replace fancy-fe-mig \
    --max-unavailable 100%

Test : 
watch -n 2 gcloud compute instance-groups list-instances fancy-fe-mig
watch -n 2 gcloud compute backend-services get-health fancy-fe-frontend --global