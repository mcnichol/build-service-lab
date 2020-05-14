#!/usr/bin/env bash

function image_registry_get_cert(){
  echo "Get $REGISTRY_URL certificate"
  openssl s_client -showcerts -servername "$REGISTRY_URL" -connect "$REGISTRY_URL:443" </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$SCRIPT_DIR/config/$REGISTRY_URL.crt"

  # Do we have enough to check validity for the Image Registry specified
  # openssl crl2pkcs7 -nocrl -certfile "$SCRIPT_DIR/config/$REGISTRY_URL.crt" | openssl pkcs7 -print_certs -noout
}

function image_registry_login(){
  docker login $REGISTRY_URL --username $REGISTRY_USERNAME --password $REGISTRY_PASSWORD 2>/dev/null
}
