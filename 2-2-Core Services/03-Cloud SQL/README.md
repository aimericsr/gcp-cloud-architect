gcloud sql tiers list - lists

https://cloud.google.com/vpc/docs/configure-private-services-access?_ga=2.176064554.-942655774.1681804002&hl=fr

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy
export SQL_CONNECTION=[SQL_CONNECTION_NAME]
./cloud_sql_proxy -instances=$SQL_CONNECTION=tcp:3306 &