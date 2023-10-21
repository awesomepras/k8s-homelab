#!/bin/bash
echo "If you have not done already, authenticate to gcloud"
echo "........"
read -p "continue"
# ---------------------------------------------
PROJECT_ID=$(gcloud projects list --format=flattened |grep projectId|awk '{print $2}')
echo "$PROJECT_ID is set"

COMPUTE_REGION=$(gcloud config list compute/region --format=flattened |awk '{print $2}')
echo "Current Region is $COMPUTE_REGION"

ZONE=$(gcloud config list compute/zone --format=flattened |awk '{print $2}')
 echo "Current zone is $ZONE"

# disktype pd-standard is for kodekloud environment you can set it to pd-balanced or pd-ssd
# disk size limit is for kodekloud env max size =50GB for all machines 
read -p "Enter cluster name: (eg: cluster-1)" CLUSTER_NAME
if [[ $CLUSTER_NAME == "" ]]; then CLUSTER_NAME=cluster-1; fi
gcloud container clusters create "$CLUSTER_NAME" \
--release-channel "stable"   --machine-type "e2-medium"  \
--image-type "COS_CONTAINERD" --disk-type "pd-standard" \
--disk-size "10" --num-nodes "3" --enable-ip-alias \
# --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver,ConfigConnector \
--workload-pool=$PROJECT_ID.svc.id.goog \
--region "$COMPUTE_REGION"  --node-locations "$COMPUTE_REGION-a"

gcloud container clusters list
read -p "CLuster created and healthy"
echo "------"
echo "getting auth token for kubeconfig"
gcloud container clusters get-credentials $CLUSTER_NAME \
    --region $COMPUTE_REGION
