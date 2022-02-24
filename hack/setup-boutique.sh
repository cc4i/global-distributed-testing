export PROJECT_ID=${PROJECT_ID}
export PROJECT_NUM=`gcloud projects list --filter PROJECT_ID=${PROJECT_ID} --format json|jq ".[].projectNumber" -r`


source ./provision.sh

# 0.Create VPC with subnet in those regions:  us-west1/europe-west1/asia-east1/asia-southeast1
# TODO: using fixed network right now?!

# 1.Create clusters to simulate web applications
zones=(us-west1-a europe-west1-b)
for loc in ${zones[@]}
do 
    cluster="webx-${loc}"
    echo "Provision GKE standard cluster ${cluster} at ${loc}"
    provison_gke ${PROJECT_ID} ${PROJECT_NUM} ${cluster} $loc

    # Rename conext 
    kubectl config rename-context gke_${PROJECT_ID}_${loc}_${cluster} ${cluster}
done
exit 1
# 1.1.Register cluster into fleet
for loc in  ${zones[@]}
do 
    cluster="webx-${loc}"

    gcloud container hub memberships register ${cluster} \
        --gke-cluster ${loc}/${cluster} \
        --enable-workload-identity \
        --project=${PROJECT_ID}
done

# 1.2 Install Anthos Service mesh; asmcli not working may not work on MacOS. Run Step 1.2 in Cloud Shell
# Download asmcli - `curl https://storage.googleapis.com/csm-artifacts/asm/asmcli > asmcli`
for loc in ${zones[@]}
do
    cluster="webx-${loc}"
    kubectl create ns istio-system --context ${cluster}


    echo "asmcli validate \
        --project_id ${PROJECT_ID} \
        --cluster_name ${cluster} \
        --cluster_location ${loc} \
        --fleet_id ${PROJECT_ID} \
        --output_dir ~/bin"

    # cd ~/bin
    # istioctl experimental precheck

    echo "asmcli install \
        --project_id ${PROJECT_ID} \
        --cluster_name ${cluster} \
        --cluster_location ${loc} \
        --fleet_id ${PROJECT_ID} \
        --output_dir ~/bin \
        --enable_all \
        --ca mesh_ca"
    echo "kubectl get deploy -n istio-system -l app=istiod -o \
        jsonpath={.items[*].metadata.labels.'istio\.io\/rev'}'{"\n"}' --context ${cluster}"
done

# 1.3 Enable Multicluster services
gcloud container hub multi-cluster-services enable \
    --project ${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[gke-mcs/gke-mcs-importer]" \
    --role "roles/compute.networkViewer" \
    --project=${PROJECT_ID}

gcloud container hub multi-cluster-services describe --project=${PROJECT_ID}

# 1.4 Enable Gateway controller
for loc in ${zones[@]}
do
    cluster="webx-${loc}"
    kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.3.0" | kubectl apply -f - --context ${cluster}

done

gcloud container hub ingress enable \
    --config-membership=/projects/${PROJECT_ID}/locations/global/memberships/webx-us-west1-a \
    --project=${PROJECT_ID}

gcloud container hub ingress describe --project=${PROJECT_ID}

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:service-${PROJECT_NUM}@gcp-sa-multiclusteringress.iam.gserviceaccount.com" \
    --role "roles/container.admin" \
    --project=${PROJECT_ID}

for loc in ${zones[@]}
do
    cluster="webx-${loc}"
    kubectl get gatewayclasses --context ${cluster}
done


# 1.3.Install Boutique as demo applications 
for loc in ${zones[@]}
do
    cluster="webx-${loc}"
    kubectl create ns boutique --context ${cluster}
    rev=`kubectl get deploy -n istio-system -l app=istiod -o json --context ${cluster}|jq '.items[].metadata.labels."istio.io/rev"' -r`
    kubectl label namespace boutique \
        istio.io/rev=$rev --overwrite --context ${cluster}
    # kubectl apply -f all-services.yaml -n boutique --context ?
    # kubectl apply -f front-external.yaml -n boutique --context ?
    
done

# 1.4.Create Gateway from Config Server
kubectl apply -f gateway.yaml -n boutique --context webx-us-west1-a
kubectl apply -f httproute.yaml -n boutique --context webx-us-west1-a



# 7. Use Istio gateway
for loc in ${zones[@]}
do 

    cluster="webx-${loc}"

    kubectl create ns gateway --context ${cluster}
    rev=`kubectl get deploy -n istio-system -l app=istiod -o json --context ${cluster}|jq '.items[].metadata.labels."istio.io/rev"' -r`

    kubectl label namespace gateway \
        istio.io/rev=${rev} --overwrite --context ${cluster}

    kubectl apply -n gateway \
        -f ./istio-ingressgateway --context ${cluster}
done
