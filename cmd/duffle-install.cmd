duffle install my-build-service -c /etc/credentials.yaml  \
    --set kubernetes_env= gke_fe-mmcnichol_us-central1-c_tbs-cluster \
    --set docker_registry=https://index.docker.io/v1/ \
    --set registry_username="mcnichol" \
    --set registry_password="dockerdemo" \
    --set custom_builder_image="build-service" \
    --set admin_users="mcnichol" \
    -f tmp/build-service-0.1.0.tgz \ 
    -m tmp/relocated.json
