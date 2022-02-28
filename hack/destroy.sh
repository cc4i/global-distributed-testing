# 0.Get PROJECT_ID
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


echo "Shutdown all clusters & clean up occupied resources."

regions=`cat ./gke-config`

for loc in ${regions[@]}
do
    cluster="testx-${loc}"

    echo "!!! SHUT DOWN ${cluster} at ${loc}!!!"
    echo "gcloud container clusters delete ${cluster} --region ${loc} --project ${PROJECT_ID} --async --quiet"
    gcloud container clusters delete ${cluster} --region ${loc} --project ${PROJECT_ID} --async --quiet
    echo "Delete cluster ${cluster} async ..."
done