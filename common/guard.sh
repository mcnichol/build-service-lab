#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE%/*}

function gcloud_login_check(){
  GCLOUD_CURRENT_AUTHENTICATED="$(gcloud auth list --filter=status:ACTIVE --format='value(account)')"

  if [ -z $GCLOUD_CURRENT_AUTHENTICATED ]; then
    gcloud auth login
  else
    echo "Currently logged in with: $GCLOUD_CURRENT_AUTHENTICATED"
    echo "To logout execute:"
    echo -e "\tgcloud auth revoke $GCLOUD_CURRENT_AUTHENTICATED"
    echo ""
  fi
}

function check_dependencies {
     # @TODO - Setup checks and feedback for dependencies
     echo "Check Dependencies"

     #You need:
     # envrc so you aren't spewing passwords like a jerk
     # kubectl `brew install kubectl`

     #If leveraging:
     #  GKE == gcloud `brew cask install google-cloud-sdk`
     #  PKS == pks  Get from network.pivotal.io
     #  TKG == ?
     #  EKS == ?
     #  AKS == ?
     #  KIND == kind `brew install kind` (Is this even possible due to networking pains?)

     # duffle
     # pb CLI
     # docker registry (BYO or existing gcr.io / index.docker.io)
     # * Worth setting up Harbor
     # * Batteries included Docker Hub is convenient

     # Potentially Optional Needs
     # openssl - Grabbing certificates if you don't have them
     # We can check if certs cover the domain
     # openssl s_client -showcerts -servername hub.docker.com -connect hub.docker.com:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERTFILE
     # openssl crl2pkcs7 -nocrl -certfile mycertificate.cer | openssl pkcs7 -print_certs -noout
 }
