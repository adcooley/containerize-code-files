#!/bin/bash

# Exit on any error
set -e

PROJECT_NAME="your project name"
CLUSTER_NAME="your cluster name"
CLOUDSDK_COMPUTE_ZONE="your compute zone"
CONTAINER="your container name"

sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster $CLUSTER_NAME
sudo /opt/google-cloud-sdk/bin/gcloud config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials $CLUSTER_NAME

docker build --no-cache -t us.gcr.io/${PROJECT_NAME}/${CONTAINER}:${CIRCLE_SHA1} .
docker tag us.gcr.io/${PROJECT_NAME}/${CONTAINER}:${CIRCLE_SHA1}_prod us.gcr.io/${PROJECT_NAME}/${CONTAINER}:prod
sudo /opt/google-cloud-sdk/bin/gcloud docker push us.gcr.io/${PROJECT_NAME}/${CONTAINER}

# The following line was necessary for an error in the gcloud sdk, and may no longer be necessary
export GOOGLE_APPLICATION_CREDENTIALS=/home/ubuntu/gcloud-service-key.json

sudo chown -R ubuntu:ubuntu /home/ubuntu/.kube
kubectl patch deployment ${CONTAINER} -p '{"spec":{"template":{"spec":{"containers":[{"name":"'"$CONTAINER"'","image":"us.gcr.io/'"$PROJECT_NAME"'/'"$CONTAINER"':'"$CIRCLE_SHA1"'"}]}}}}'
