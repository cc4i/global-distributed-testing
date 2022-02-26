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

# 1.Load functions
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

# 3.Clean up not reqiured clusters
echo "Clear up clusters if there's any!?"
existed_clusters=`gcloud container clusters list --format "value(NAME)"|grep "testx-"`

required_clusters=()
for loc in ${regions[@]}
do
    cluster="testx-${loc}"
    required_clusters[${#required_clusters[@]}]=${cluster}
done

for ec in ${existed_clusters[@]}
do
    
    # case ! "${existed_clusters[@]}" in  *"${cluster}-xxx"*) echo "not found ->${cluster}" ;; esac
    if [[ ${required_clusters[@]} =~ ${ec} ]]
    then
        echo ""
    else
        echo "Not FOUND!!!"
        region=`echo ${ec} |awk -F- '{print $2"-"$3}'`
        echo "gcloud container clusters delete ${ec} --region ${region} --project ${PROJECT_ID} --async --quiet"
        gcloud container clusters delete ${ec} --region ${region} --project ${PROJECT_ID} --async --quiet
        echo "Delete cluster ${ec} async ..."
    fi
done

