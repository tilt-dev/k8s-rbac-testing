#!/bin/bash
# Deletes the secret used by an exec credential script
# (so that it gets unauthorized errors).

set -euo pipefail

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME

if [ $# -ne 1 ]; then
    echo "Error: expected exactly 2 arguments.
Usage: $BASENAME [namespace]

Deletes the secret used by an exec credential script (so that it gets unauthorized errors).
"
    exit 1
fi

NAMESPACE="$1"
USER="$NAMESPACE-user"
SECRET_NAME=$(kubectl get serviceaccount $USER -n $NAMESPACE -o "jsonpath={.secrets[*].name}")
kubectl delete secret -n $NAMESPACE $SECRET_NAME
