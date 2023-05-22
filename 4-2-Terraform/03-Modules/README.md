https://registry.terraform.io

https://registry.terraform.io/modules/terraform-google-modules/network/google/7.0.0
https://developer.hashicorp.com/terraform/language/modules/sources

git clone https://github.com/terraform-google-modules/terraform-google-network
cd terraform-google-network
git checkout tags/v6.0.1 -b v6.0.1

gcloud config list --format 'value(core.project)'

gcloud auth application-default login


When using a new module for the first time, you must run either terraform init or terraform get to install the module. When either of these commands is run, Terraform will install any new modules in the .terraform/modules directory within your configuration's working directory. For local modules, Terraform will create a symlink to the module's directory. Because of this, any changes to local modules will be effective immediately, without your having to re-run terraform get.

tee -a README.md <<EOF
# GCS static website bucket
This module provisions Cloud Storage buckets configured for static website hosting.
EOF


cd ~
curl https://raw.githubusercontent.com/hashicorp/learn-terraform-modules/master/modules/aws-s3-static-website-bucket/www/index.html > index.html
curl https://raw.githubusercontent.com/hashicorp/learn-terraform-modules/blob/master/modules/aws-s3-static-website-bucket/www/error.html > error.html

gsutil cp *.html gs://YOUR-BUCKET-NAME

https://storage.cloud.google.com/YOUR-BUCKET-NAME/index.html