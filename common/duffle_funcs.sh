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


function duffle_relocate_build_dependencies(){
    echo "Importing Build Dependencies to $REGISTRY_URL"

    duffle relocate -f $SCRIPT_DIR/tmp/build-service-0.1.0.tgz -m $SCRIPT_DIR/tmp/relocated.json -p              $REGISTRY_PATH
}
