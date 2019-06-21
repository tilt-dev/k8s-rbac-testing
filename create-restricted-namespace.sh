#!/bin/bash

set -eu
set -o pipefail

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME

if [ $# -ne 1 ]; then
    echo "Error: expected exactly 1 argument.
Usage: $BASENAME [namespace]

Creates:
- a namespace
- a service account
- a kubeconfig that logs into the service account
- RBAC rules that restrict the service account's access to the given namespace"
    exit 1
fi

NAMESPACE="$1"
USER="$NAMESPACE-user"

# docker-for-desktop has a default binding that gives service accounts access to everything.
# See: https://github.com/docker/for-mac/issues/3694
BINDING=$(kubectl get clusterrolebinding docker-for-desktop-binding --ignore-not-found)
if [ "$BINDING" != "" ]; then
    echo "WARNING: Docker-for-Desktop has a RBAC rule that grants access to all service accounts."
    read -p "Delete the rule (y/n)? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        kubectl delete clusterrolebinding docker-for-desktop-binding
    else
        echo "Canceling namespace creation..."
        exit 1
    fi
fi

./create-namespace.sh $NAMESPACE

KUBECFG_FILE=$(mktemp)
./create-service-account.sh $NAMESPACE $KUBECFG_FILE

# Create the role bindings
sed "s/\$NAMESPACE/$NAMESPACE/g" roles.yaml | kubectl apply -f -
sed "s/\$NAMESPACE/$NAMESPACE/g" node-access.yaml | kubectl apply -f -

set +x
echo "Restricted namespace set up! Hooray!

To use it, run:
export KUBECONFIG=$KUBECFG_FILE

or just prefix all kubectl commands with:
KUBECONFIG=$KUBECFG_FILE kubectl ...

To delete it, run
kubectl delete namespace $NAMESPACE"
    

