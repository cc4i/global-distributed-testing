export PROJECT_ID=${PROJECT_ID}

regions=`cat ./gke-config`
region=`echo ${regions}|awk '{print $1}'`
master_cluster="testx-${region}"

echo ""
echo "Retrieve credential from master clutser => ${master_cluster}"
gcloud container clusters get-credentials ${master_cluster} --region ${region} --project ${PROJECT_ID}

echo "Deploy manifests to master clutser => ${master_cluster}"
kubeclt create ns locust || true
kustomize build manifests/master/. | kubeclt apply -f -
