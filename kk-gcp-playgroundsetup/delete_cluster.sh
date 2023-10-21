#!/bin/sh
echo "CLEANUP:::"
CLUSTER_NAME=$(gcloud container clusters list --format=text |grep -w "^name:" |awk '{print $2}')
COMPUTE_REGION=$(gcloud config list compute/region --format=flattened |awk '{print $2}')
ZONE=$(gcloud config list compute/zone --format=flattened |awk '{print $2}')

gcloud container clusters delete $CLUSTER_NAME --location=$COMPUTE_REGION

echo "ALL DONE"
read -p "remove gcloud configuration?:(y/n)" yn
case $yn in 
  y)
    k config get-contexts
    k config delete-context $(k config get-clusters  |grep -v NAME)
    gcloud auth revoke --all --quiet
    ;;
  n)
    gcloud auth list
    ;;
  *)
    echo "invalid option"
    exit
    ;;
esac
