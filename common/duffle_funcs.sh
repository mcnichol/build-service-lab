#!/usr/bin/env bash

function duffle_create_credentials(){
  echo "Create Credentials.yaml"

cat << EOF>$SCRIPT_DIR/etc/credentials.yaml
name: build-service-credentials
credentials:
 - name: kube_config
   source:
       path: "/Users/$(whoami)/.kube/config"
   destination:
     path: "/root/.kube/config"
 - name: ca_cert
   source:
     path: "$SCRIPT_DIR/etc/docker_io.crt"
   destination:
     path: "/cnab/app/cert/ca.crt"
EOF

}

