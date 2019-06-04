#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Error: expected exactly 1 argument.
Usage: namespace.sh [namespace]"
    exit 1
fi

NAMESPACE="$1"
USER="$NAMESPACE-user"

# uncomment the next line during development
# set -euxo pipefail
set -euo pipefail

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

# Get the current context
CONTEXT=$(kubectl config current-context)

# Create the namespace
sed "s/\$NAMESPACE/$NAMESPACE/g" namespace.yaml | kubectl apply -f -

# Create the role bindings
sed "s/\$NAMESPACE/$NAMESPACE/g" access.yaml | kubectl apply -f -

# Pull the name of the secret out of the service account object,
# so we can authenticate as that user.
kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}"
SECRET_DATA=$(kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}")

# Pull the certificate data and the token out of secrets.
TOKEN=$(kubectl get secrets -n $NAMESPACE $SECRET_DATA -o "jsonpath={.data.token}" | base64 --decode)
CERT=$(kubectl get secrets -n $NAMESPACE $SECRET_DATA -o "jsonpath={.data['ca\.crt']}")

# Create a temporary kubeconfig and use it for all future calls.
KUBECFG_FILE=$(mktemp)
kubectl config view --minify > $KUBECFG_FILE
export KUBECONFIG=$KUBECFG_FILE

# Create a user with this cert data and token.
kubectl config set-credentials $USER --token $TOKEN
kubectl config set users.$USER.client-key-data $CERT
kubectl config set-context $CONTEXT --user=$USER --namespace=$NAMESPACE

CLUSTER_NAME=$(kubectl config view --minify -o "jsonpath={.clusters[*].name}")
INSECURE=$(kubectl config view --minify -o "jsonpath={.clusters[*].cluster.insecure-skip-tls-verify}")
if [ "$INSECURE" == "" ]; then
    kubectl config set clusters.$CLUSTER_NAME.certificate-authority-data $CERT
    kubectl config unset clusters.$CLUSTER_NAME.certificate-authority
fi

set +x
echo "Restricted namespace set up! Hooray!

To use it, run:
export KUBECONFIG=$KUBECFG_FILE

or just prefix all kubectl commands with:
KUBECONFIG=$KUBECFG_FILE kubectl ...

To delete it, run
kubectl delete namespace $NAMESPACE"
    

