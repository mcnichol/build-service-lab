#!/usr/bin/env bash

function duffle_create_credentials(){
  echo "Create Credentials.yaml"

cat << EOF>$SCRIPT_DIR/etc/credentials.yaml
name: build-service-credentials
credentials:
 - name: kube_config
   source:
       path: "$SCRIPT_DIR/config/kubeconfig.yaml"
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

    duffle relocate -f $SCRIPT_DIR/tmp/build-service-0.1.0.tgz -m $SCRIPT_DIR/tmp/relocated.json -p $REGISTRY_PATH
}

function duffle_create_tbs(){
    KUBE_NAMESPACE="duffle"
    echo "Executing"
echo """
    KUBE_NAMESPACE=$KUBE_NAMESPACE KUBECONFIG=$KUBECONFIG GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS
    duffle install "$DUFFLE_CLAIM" --driver k8s -c etc/credentials.yaml
    --set kubernetes_env="$CLUSTER_CONTEXT"
    --set docker_registry="$REGISTRY_URL"
    --set registry_username="$REGISTRY_USERNAME"
    --set registry_password="$REGISTRY_PASSWORD"
    --set custom_builder_image="build-service"
    --set admin_users="mcnichol"
    -f "$SCRIPT_DIR/tmp/build-service-0.1.0.tgz"
    -m "$SCRIPT_DIR/tmp/relocated.json"
"""
    sleep 2s

    GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_APPLICATION_CREDENTIALS" kubectl create namespace $KUBE_NAMESPACE --kubeconfig $KUBECONFIG

    KUBE_NAMESPACE=$KUBE_NAMESPACE KUBECONFIG=$KUBECONFIG GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS duffle install "$DUFFLE_CLAIM" --driver k8s -c etc/credentials.yaml \
    --set kubernetes_env="$CLUSTER_CONTEXT" \
    --set docker_registry="$REGISTRY_URL" \
    --set registry_username="$REGISTRY_USERNAME" \
    --set registry_password="$REGISTRY_PASSWORD" \
    --set custom_builder_image="build-service" \
    --set admin_users="mcnichol" \
    -f "$SCRIPT_DIR/tmp/build-service-0.1.0.tgz" \
    -m "$SCRIPT_DIR/tmp/relocated.json"
}
