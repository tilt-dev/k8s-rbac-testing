#!/bin/bash
# Create a service account

set -euo pipefail

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME

if [ $# -ne 2 ]; then
    echo "Error: expected exactly 2 arguments.
Usage: $BASENAME [namespace] [kubeconfig-path]

Creates a service account and a kubeconfig that logs into the service account
with the current context.

Will overwrite the file at kubeconfig-path"
    exit 1
fi

NAMESPACE="$1"
KUBECFG_FILE="$2"
USER="$NAMESPACE-user"
CONTEXT=$(kubectl config current-context)

sed "s/\$NAMESPACE/$NAMESPACE/g" service-account.yaml | kubectl apply -f -

# Pull the name of the secret out of the service account object,
# so we can authenticate as that user.
kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}"
SECRET_DATA=$(kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}")

# Pull the certificate data and the token out of secrets.
TOKEN=$(kubectl get secrets -n $NAMESPACE $SECRET_DATA -o "jsonpath={.data.token}" | base64 --decode)
CERT=$(kubectl get secrets -n $NAMESPACE $SECRET_DATA -o "jsonpath={.data['ca\.crt']}")

# Create a temporary kubeconfig and use it for all future calls.
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
