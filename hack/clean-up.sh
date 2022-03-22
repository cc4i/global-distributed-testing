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


# 2. Unregister cluster from fleet & delete
regions=`cat ./gke-config`
# master_cluster="testx-`echo ${regions}|awk '{print $1}'`"
# echo "master_cluster => ${master_cluster}"
for loc in ${regions[@]}
do 
    cluster="testx-${loc}"
    echo "Unregister ${cluster} from fleet in ${PROJECT_ID}."
    gcloud container hub memberships unregister ${cluster} \
        --project=${PROJECT_ID} \
        --gke-cluster=${loc}/${cluster}
    if [ $? -ne 0 ]
    then
        gcloud container hub memberships delete --quiet ${cluster} 
    fi

    echo "Delete ${cluster} from ${PROJECT_ID}."
    gcloud container clusters delete ${cluster} \
        --project=${PROJECT_ID} \
        --region=${loc} \
        --async || true
done