#!/bin/sh
echo "CLEANUP:::"
CLUSTER_NAME=$(gcloud container clusters list --format=text |grep -w "^name:" |awk '{print $2}')
ZONE=$(gcloud config list compute/zone --format=flattened |awk '{print $2}')
gcloud container clusters delete $CLUSTER_NAME -z=$ZONE

echo "ALL DONE"
read -p "remove gcloud configuration?:(y/n)" : y/n
case $y/n in 
  y)
    gcloud auth auth revoke --all --quiet
    ;;
  n)
    gcloud auth list
    ;;
  *)
    echo "invalid option"
    exit
    ;;
esac
