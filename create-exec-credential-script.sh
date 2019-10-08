#!/bin/bash
# Create an exec credential script
# A bash script that produces ExecCredential objects, similar to aws-iam-authenticator.

set -euo pipefail

BASENAME=$(basename $0)
DIRNAME=$(dirname $0)
cd $DIRNAME

if [ $# -ne 1 ]; then
    echo "Error: expected exactly 1 argument.
Usage: $BASENAME [token]

Writes a new bash script to stdout. This bash script satisfies the ExecCredential API

https://godoc.org/k8s.io/client-go/pkg/apis/clientauthentication#ExecCredential
"
    exit 1
fi

TOKEN="$1"
sed -e "s/__TOKEN__/$TOKEN/g" exec-credential-script.sh
