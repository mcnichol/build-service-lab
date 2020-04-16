#!/usr/bin/env bash

function image_registry_get_cert(){
  echo "Get $REGISTRY_URL certificate"
}

function image_registry_login(){
  docker login $REGISTRY_URL --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD 2>/dev/null
}
