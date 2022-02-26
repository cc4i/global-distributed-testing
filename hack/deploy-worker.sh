export PROJECT_ID=${PROJECT_ID}

cp /workspace/kustomization.yaml manifests/worker/kustomization.yaml
cat manifests/worker/kustomization.yaml
gcloud version
regions=`cat ./gke-config`
master_cluster="testx-`echo ${regions}|awk '{print $1}'`"
echo "master_cluster => ${master_cluster}"

for loc in ${regions[@]}
do
cluster="testx-${loc}"
if [ ${master_cluster} != ${cluster} ]
    echo "Deploying into ${cluster} ... ..."
    gcloud container clusters get-credentials ${cluster} --region ${loc} --project ${PROJECT_ID}
    kubeclt create ns locust || true
    kubectl kustomize manifests/worker/. | kubeclt apply -f -
    echo "Deploying into ${cluster} ... ...done"
    echo ""
then
fi
done
