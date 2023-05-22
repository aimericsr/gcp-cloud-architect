gcloud config list --format 'value(core.project)'

terraform show
export GOOGLE_APPLICATION_CREDENTIALS=key.json
terraform init -migrate-state

terraform refresh


Warning: Importing infrastructure manipulates Terraform state in ways that could leave existing Terraform projects in an invalid state. Make a backup of your terraform.tfstate file and .terraform directory before using Terraform import on a real Terraform project, and store them securely.


Import State : 

docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest
git clone https://github.com/hashicorp/learn-terraform-import.git

import docker container : 
terraform import docker_container.web $(docker inspect -f {{.ID}} hashicorp-learn)

There are two approaches to update the configuration in docker.tf to match the state you imported. You can either accept the entire current state of the resource into your configuration as-is or select the required attributes into your configuration individually. Each of these approaches can be useful in different circumstances.

Using the current state is often faster, but can result in an overly verbose configuration because every attribute is included in the state, whether it is necessary to include in your configuration or not.

Individually selecting the required attributes can lead to more manageable configuration, but requires you to understand which attributes need to be set in the configuration.

terraform show -no-color > docker.tf
terraform plan

docker image inspect <IMAGE-ID> -f {{.RepoTags}}
docker ps --filter "name=hashicorp-learn"

https://www.hashicorp.com/resources/what-is-mutable-vs-immutable-infrastructure
help for import : https://github.com/GoogleCloudPlatform/terraformer