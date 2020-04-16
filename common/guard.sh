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
     CHECK_INSTALLED="$(command -v duffle)"
     if [ "$?" == "1" ]; then
       echo "Downloading duffle-cli for Mac"
       curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648381/download -o $SCRIPT_DIR/bin/duffle --progress
       chmod 755 $SCRIPT_DIR/bin/duffle
     fi

     CHECK_INSTALLED="$(command -v pb)"
     if [ "$?" == "1" ]; then
       echo "Downloading pb-cli for Mac"
       curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648384/download -o $SCRIPT_DIR/bin/pb --progress
       chmod 755 $SCRIPT_DIR/bin/pb
     fi

     CHECK_INSTALLED="$(ls $SCRIPT_DIR/tmp/build-service-0.1.0.tgz > /dev/null 2>&1)"
     if [ "$?" == "1" ]; then
       echo "Downloading build-service-0.1.0"
       curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648378/download -o "$SCRIPT_DIR/tmp/build-service-0.1.0.tgz" --progress
     fi

     # * Worth setting up Harbor
     # * Batteries included Docker Hub is convenient

     # Potentially Optional Needs
     # openssl - Grabbing certificates if you don't have them

     # openssl s_client -showcerts -servername hub.docker.com -connect hub.docker.com:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERTFILE

     # We can check if certs cover the domain
     # openssl crl2pkcs7 -nocrl -certfile mycertificate.cer | openssl pkcs7 -print_certs -noout
 }
