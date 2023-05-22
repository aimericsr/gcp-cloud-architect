gsutil -m cp -r gs://spls/gsp053/orchestrate-with-kubernetes .
cd orchestrate-with-kubernetes/kubernetes

gcloud container clusters get-credentials CLUSTER_NAME \
    --zone=COMPUTE_ZONE

get docs : 
kubectl explain deployment
kubectl explain deployment --recursive
kubectl explain deployment.metadata.name

create deployments : 
kubectl create -f deployments/auth.yaml
kubectl get deployments
kubectl get replicasets
kubectl get pods

kubectl create -f services/auth.yaml

kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml

kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml

kubectl get services frontend

curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`

scale :
kubectl explain deployment.spec.replicas
kubectl scale deployment hello --replicas=5 or kubectl apply -f deployments/hello.yaml
kubectl get pods | grep hello- | wc -l

rolling update : 
kubectl edit deployment hello -> edit the file and automatically applied the change
kubectl rollout history deployment/hello

kubectl rollout pause deployment/hello
see the different container version during the update (there should be pods with 1.0.0 and others with 2.0.0): 
kubectl get pods -o jsonpath --template='{range .items[*]}{.metadata.name}{"\t"}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

kubectl rollout resume deployment/hello
kubectl rollout status deployment/hello

rollback update : 
kubectl rollout undo deployment/hello
kubectl rollout history deployment/hello

canary deployment : 
cat deployments/hello-canary.yaml
kubectl create -f deployments/hello-canary.yaml
kubectl get deployments

On the hello service, the selector uses the app:hello selector which will match pods in both the prod deployment(hello) and canary deployment(hello-canary). 
However, because the canary deployment has a fewer number of pods, it will be visible to fewer users.

verify witch version is use for a request : 
curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version
there should be 75% of requests served by the 1.0.0 and 25% served by the 2.0.0 (3 pods of 1.0.0 and 1 pod of 2.0.0)

if you want that a user alawys get the same version, you can use sessionAffinity. If the IP is the same, the request will have the same version of the app : 

kind: Service
apiVersion: v1
metadata:
  name: "hello"
spec:
  sessionAffinity: ClientIP
  selector:
    app: "hello"
  ports:
    - protocol: "TCP"
      port: 80
      targetPort: 80


blue / green deployments : 
the service will forward request to the new pods only when all the pods with the newer version are ready.
Note: A major downside of blue-green deployments is that you will need to have at least 2x the resources in your cluster necessary to host your application. Make sure you have enough resources in your cluster before deploying both versions of the application at once.

match the blue deployment because the version is specified : 

(services/hello-blue.yaml)
kind: Service
apiVersion: v1
metadata:  
    name: "hello"
spec:  
    selector:    
        app: "hello"    
        version: 1.0.0  
    ports:    
      - protocol: "TCP"      
        port: 80      
        targetPort: 80

update the service to only match the version 1.0.0 (blue deployment):
kubectl apply -f services/hello-blue.yaml

create the green deployment(2.0.0): 
kubectl create -f deployments/hello-green.yaml

update the service to point to the new version (all new request will be forward to this service): 
kubectl apply -f services/hello-green.yaml

(services/hello-green.yaml)
kind: Service
apiVersion: v1
metadata:  
    name: "hello"
spec:  
    selector:    
        app: "hello"    
        version: 2.0.0  
    ports:    
      - protocol: "TCP"      
        port: 80      
        targetPort: 80

verify with the command : 
curl -ks https://`kubectl get svc frontend -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"`/version

rollback : 
kubectl apply -f services/hello-blue.yaml

