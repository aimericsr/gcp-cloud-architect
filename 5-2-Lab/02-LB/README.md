gcloud services enable compute.googleapis.com


gsutil mb gs://fancy-store-$DEVSHELL_PROJECT_ID

git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
nvm install --lts
cd microservices
npm start