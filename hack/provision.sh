
# Provision GKE Autopilot
provison_autopilot() {

    project_id=$1
    cluster=$2
    region=$3

    gcloud container --project "play-with-anthos-340801" clusters create-auto "${cluster}" \
        --region "${region}" \
        --release-channel "regular" \
        --network "projects/${project_id}/global/networks/default" \
        --subnetwork "projects/${project_id}/regions/${region}/subnetworks/default" \
        --cluster-ipv4-cidr "/17" \
        --services-ipv4-cidr "/22"

}

# Provision Regioanl GKE Standard 
provison_gke() {
    project_id=$1
    project_number=$2
    cluster=$3
    zone=$4
    region=`echo $zone|awk -F- '{print $1"-"$2}'`
    subnet=${region}
    vm='n2d-standard-4'

    gcloud container --project ${project_id} clusters create ${cluster} \
    --zone ${zone} \
    --node-locations ${zone} \
    --no-enable-basic-auth \
    --cluster-version "1.21.6-gke.1500" \
    --release-channel "regular" \
    --machine-type ${vm} \
    --image-type "COS_CONTAINERD" \
    --disk-type "pd-standard" \
    --disk-size "100" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --max-pods-per-node "110" \
    --num-nodes "1" \
    --enable-autoscaling --min-nodes "1" --max-nodes "10" \
    --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM \
    --enable-ip-alias \
    --network "projects/${project_id}/global/networks/custom-vpc-1" \
    --subnetwork "projects/${project_id}/regions/${region}/subnetworks/${subnet}" \
    --enable-intra-node-visibility \
    --default-max-pods-per-node "110" \
    --enable-dataplane-v2 \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
    --enable-autoupgrade --max-surge-upgrade 1 --max-unavailable-upgrade 0 \
    --enable-autorepair \
    --enable-autoprovisioning --min-cpu 4 --max-cpu 80 --min-memory 16 --max-memory 320 \
    --enable-autoprovisioning-autorepair \
    --enable-autoprovisioning-autoupgrade --autoprovisioning-max-surge-upgrade 1 --autoprovisioning-max-unavailable-upgrade 0 \
    --labels mesh_id=proj-${project_number} \
    --workload-pool "${project_id}.svc.id.goog" \
    --enable-shielded-nodes
}