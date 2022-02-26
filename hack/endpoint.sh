export PROJECT_ID=${PROJECT_ID}

regions=`cat ./hack/gke-config`
region=`${regions}|awk '{print $1}'`
master_cluster="testx-${region}"
cat manifests/master/kustomization.yaml

gcloud container clusters get-credentials ${master_cluster} --region ${region} --project ${PROJECT_ID}
external_ip=""; while [ -z $external_ip ]; do echo "Waiting for end point..."; external_ip=$(kubectl get svc locust-master -n locust --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}" || true); [ -z "$external_ip" ] && sleep 10; done; echo "End point ready-" && echo $external_ip; export endpoint=$external_ip
echo ${endpoint}

sed -i 's/MASTER_HOST/'${endpoint}'/g' manifests/worker/kustomization.yaml
cat manifests/worker/kustomization.yaml
cp manifests/worker/kustomization.yaml /workspace
echo "Access => http://${endpoint}/"
