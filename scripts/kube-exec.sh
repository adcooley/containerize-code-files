#!/bin/bash
# Run from the current directory

# Exit on any error
set -e

# Example Usage: ./kube-exec -x minikube -c nginx

while getopts ":x:c:" opt; do
  case $opt in
    x) CONTEXT="$OPTARG"
    ;;
    c) CONTAINER="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

# Switch to the correct kubernetes context
kubectl config use-context $CONTEXT

# Get the first available pod starting with the provided container name
container=$(kubectl get pod | grep $CONTAINER | awk ‘END {print $1}’)

# SSH into the container
kubectl exec $container -it bash
