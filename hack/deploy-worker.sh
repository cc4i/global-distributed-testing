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

cp /workspace/kustomization.yaml ../manifests/worker/kustomization.yaml
cat ../manifests/worker/kustomization.yaml
gcloud version
regions=`cat ./gke-config`
master_cluster="testx-`echo ${regions}|awk '{print $1}'`"
echo "master_cluster => ${master_cluster}"

for loc in ${regions[@]}
do
    cluster="testx-${loc}"
    if [ ${master_cluster} != ${cluster} ]
    then
        echo "Deploying into ${cluster} ... ..."
        gcloud container clusters get-credentials ${cluster} --region ${loc} --project ${PROJECT_ID}
        kubectl create ns locust || true
        kubectl kustomize ../manifests/worker | kubectl apply -f -
        echo "Deploying into ${cluster} ... ...done"
        echo ""

    fi
done
