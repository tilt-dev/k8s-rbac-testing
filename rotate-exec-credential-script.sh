#!/bin/bash
# Rotates the token in an exec credential script,
# deleting the old one (so that it gets unauthorized errors)
# and creating a new one.

set -euo pipefail

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME

if [ $# -ne 2 ]; then
    echo "Error: expected exactly 2 arguments.
Usage: $BASENAME [namespace] [script]

Rotates the token in an exec credential script,
deleting the old one (so that it gets unauthorized errors)
and creating a new one.
"
    exit 1
fi

NAMESPACE="$1"
EXEC_CREDENTIAL_SCRIPT="$2"
USER="$NAMESPACE-user"
SECRET_NAME=$(kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}")
kubectl delete secret -n $NAMESPACE $SECRET_NAME

# Wait for the new secret to be created.
sleep 1

NEW_SECRET_NAME=$(kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}")
NEW_TOKEN=$(kubectl get secrets -n $NAMESPACE $NEW_SECRET_NAME -o "jsonpath={.data.token}" | base64 --decode)
./create-exec-credential-script.sh $NEW_TOKEN > $EXEC_CREDENTIAL_SCRIPT
