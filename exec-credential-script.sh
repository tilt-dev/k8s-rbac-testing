#!/bin/bash
# Auto-generated with create-exec-credential-script.sh

LOG_FILE="$0.log"
echo "$(date): Accessing $0" >> $LOG_FILE

cat <<EOF
{
  "kind": "ExecCredential",
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "status": {
    "token": "__TOKEN__"
  }
}
EOF
