sudo google_metadata_script_runner startup


ab -n 500000 -c 1000 http://$LB_IP/