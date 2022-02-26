# Pass neccensary argument here due to Cloud Build not to pass in.
# Be careful, scripts here will be execute all, still keep running and not stop event if meet error!!! 
COMMIT_SHA=$1

# Retrieve PROJECT_ID
echo "Inside => ${PROJECT_ID}"
export PROJECT_ID=${PROJECT_ID}
if [ -z "${PROJECT_ID}" ]
then
    export PROJECT_ID=`gcloud config get-value project`
    if [ -z "${PROJECT_ID}" ]
    then
        echo "Pls setup project id to run this script."
        exit 1
    fi
    echo "Using defautl project id => ${PROJECT_ID} instead."

fi  
export PROJECT_NUM=`gcloud projects list --filter PROJECT_ID=${PROJECT_ID} --format "value(PROJECT_NUMBER)"`
env

# Prepare for deployment
cp /workspace/kustomization.yaml ../manifests/worker/kustomization.yaml
cat ../manifests/worker/kustomization.yaml
gcloud version
regions=`cat ./gke-config`
master_cluster="testx-`echo ${regions}|awk '{print $1}'`"
echo "master_cluster => ${master_cluster}"

# Deploy into clusters
for loc in ${regions[@]}
do
    cluster="testx-${loc}"
    if [ ${master_cluster} != ${cluster} ]
    then
        echo "Deploying into ${cluster} ... ..."
        gcloud container clusters get-credentials ${cluster} --region ${loc} --project ${PROJECT_ID}
        kubectl create ns locust || true

        echo ""
        cd ../manifests/worker
        echo "image=locust-tasks=us-docker.pkg.dev/${PROJECT_ID}/gdt-repo/locust-tasks:${COMMIT_SHA}"
        kustomize edit set image locust-tasks=us-docker.pkg.dev/${PROJECT_ID}/gdt-repo/locust-tasks:${COMMIT_SHA}
        kustomize build | kubectl apply -f -

        echo "Deploying into ${cluster} ... ...done"
        echo ""

    fi
done
