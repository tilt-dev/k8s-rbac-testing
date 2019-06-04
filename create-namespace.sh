#!/bin/bash
#
# Create a namespace

set -euo pipefail

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME

if [ $# -ne 1 ]; then
    echo "Error: expected exactly 1 argument.
Usage: $BASENAME [namespace]

Creates a namespace in the current kubectl context"
    exit 1
fi

NAMESPACE="$1"
sed "s/\$NAMESPACE/$NAMESPACE/g" namespace.yaml | kubectl apply -f -
