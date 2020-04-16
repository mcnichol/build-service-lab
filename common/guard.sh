#!/usr/bin/env bash

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
     echo "Checking Dependencies"

     CHECK_INSTALLED="$(command -v direnv)"
     if [ "$?" == "1" ]; then
         echo "Direnv is not installed."
         echo ""
         echo "Direnv is recommended to keep your environment secrets scoped to only this folder."
         read -p "Would you like to setup Direnv? [y/N]: " SETUP_DIRENV

         if [ "${SETUP_DIRENV:0:1}" == "y" ]; then
           brew install direnv

           echo "PATH_add bin" > "$SCRIPT_DIR/.envrc"
           echo 'echo ".envrc file was setup in $(pwd)/.envrc"' >> "$SCRIPT_DIR/.envrc"
           echo 'echo "Add environment variables to me!"' >> "$SCRIPT_DIR/.envrc"

           if [ "$SHELL" == "/bin/zsh" ]; then
               echo "To finish direnv setup execute:"
               echo "  echo 'eval \"\$(direnv hook zsh)\"' >> ~/.zshrc && source ~/.zshrc"
               echo ""
           elif [ "$SHELL"== "/bin/bash" ]; then
               echo ""
               echo "To finish direnv setup execute:"
               echo "  echo 'eval \"\$(direnv hook bash)\"' >> ~/.bashrc && source ~/.bashrc"
           else
               echo "Check docs for setting up hooks in your shell: https://direnv.net/"
           fi

           echo "Once your hook is set, allow your .envrc properties"
           echo ""
           echo "Execute command:"
           echo "  direnv allow"
           exit
          fi
 fi


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
