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

regions=`cat ./gke-config`
region=`echo ${regions}|awk '{print $1}'`
master_cluster="testx-${region}"

echo ""
echo "Retrieve credential from master clutser => ${master_cluster}"
echo "gcloud container clusters get-credentials ${master_cluster} --region ${region} --project ${PROJECT_ID}"
gcloud container clusters get-credentials ${master_cluster} --region ${region} --project ${PROJECT_ID}

echo "Deploy manifests to master clutser => ${master_cluster}"
kubeclt create ns locust || true
kubectl kustomize build manifests/master | kubeclt apply -f -
