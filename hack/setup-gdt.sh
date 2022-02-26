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


source ./provision.sh

# 2. Create distributed load testing clusters. Read config file, ignore if has existed
regions=`cat ./gke-config`
master_cluster="testx-`echo ${regions}|awk '{print $1}'`"
echo "master_cluster => ${master_cluster}"
for loc in ${regions[@]}
do 
    cluster="testx-${loc}"
    echo "Check cluster => ${cluster}"
    status=`gcloud container clusters describe ${cluster} --project ${PROJECT_ID} --region ${loc} --format "value(status)"`
    if [ "${status}" == "RUNNING" ]
    then
        echo "GKE Autopilot => ${cluster} is up and runing."
        gcloud container clusters get-credentials ${cluster} --region ${loc} --project ${PROJECT_ID}
        kubectl config rename-context gke_${PROJECT_ID}_${loc}_${cluster} ${cluster} || true
        kubectl config get-contexts
        kubectl get svc --context ${cluster}
        which kubectl
        echo $PATH
        cp ~/.kube/config /workspace/.
        echo "..."

    else
        echo "Provision a GKE Autopilot ${cluster} at ${loc}."
        provison_autopilot ${PROJECT_ID} ${cluster} ${loc}
        if [ $? -ne 0 ]
        then
            echo "Failed to privion cluster => ${cluster}!!!"
            exit 1
        fi 
        # Rename context to cluster name.
        kubectl config rename-context gke_${PROJECT_ID}_${loc}_${cluster} ${cluster} || true
        echo "..."
    fi
    
done

# 3.Create a triger for Cloud Build

# 4.Create delivery pipeline for master
# 5.Create delivery pipeline for worker

# 6.Create Pub/Sub for deployment pipeline

