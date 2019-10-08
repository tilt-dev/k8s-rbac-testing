#!/bin/bash
# Auto-generated with create-exec-credential-script.sh

cat <<EOF
{
  "kind": "ExecCredential",
  "apiVersion": "client.authentication.k8s.io/v1beta1",
  "status": {
    "token": "__TOKEN__"
  }
}
EOF
