#!/usr/bin/env bash

function check_variables {
    echo ""
    echo -n "Checking for required variables..."

    if [ -z "$PIVOTAL_AUTH_TOKEN" ];then
        echo ""
        echo "PIVOTAL_AUTH_TOKEN required for downloading pb, duffle, and build-dependences from Pivnet"
        echo "Consider adding \`export PIVOTAL_AUTH_TOKEN=\"YOUR_TOKEN\"\` to .envrc"
        echo ""
        read -p "Please enter your Pivotal Auth Token: " PIVOTAL_AUTH_TOKEN
        if [ "$PIVOTAL_AUTH_TOKEN" == "" ]; then
            echo "Cannot proceed without PIVOTAL_AUTH_TOKEN.  Bailing..."
            echo ""
            echo "You can find your Auth Token at https://network.pivotal.io under Username > Edit Profile > Legacy API Token"
            exit
        fi
    fi


    if [ -z "$REGISTRY_URL" ];then
        echo ""
        echo "REGISTRY_URL required for uploading dependency images"
        echo "Consider adding \`export REGISTRY_URL=\"index.docker.io\"\` to .envrc"
        echo ""
        read -p "Please enter a Registry URL [index.docker.io]: " REGISTRY_URL
        if [ "$REGISTRY_URL" == "" ]; then
            echo "Setting Registry URL to: index.docker.io"
            echo ""
            REGISTRY_URL="index.docker.io"
        fi
    fi

    if [ -z "$REGISTRY_USERNAME" ];then
        echo ""
        echo "REGISTRY_USERNAME required for Authenticating to registry"
        echo "Consider adding \`export REGISTRY_USERNAME=\"username\"\` to .envrc"
        echo ""
        read -p "Please enter the username for $REGISTRY_URL: " REGISTRY_USERNAME
        echo ""
        if [ "$REGISTRY_USERNAME" == "" ]; then
        echo ""
            echo "Cannot proceed without REGISTRY_USERNAME.  Bailing..."
            exit
        fi
    fi

    if [ -z "$REGISTRY_PATH" ];then
        echo ""
        echo "REGISTRY_PATH required for uploading dependency images"
        echo "Consider adding \`export REGISTRY_PATH=\"path\"\` to .envrc"
        echo ""
        read -p "Please enter a Registry path: " REGISTRY_PATH
        if [ "$REGISTRY_PATH" == "" ]; then
            echo "Cannot proceed without REGISTRY_PATH.  Bailing..."
            exit
        fi
    fi

    if [ -z "$REGISTRY_PASSWORD" ];then
        echo ""
        echo "REGISTRY_PASSWORD required for Authenticating to registry"
        echo "Consider adding \`export REGISTRY_PASSWORD=\"password\"\` to .envrc"
        echo ""
        read -p "Please enter the password for $REGISTRY_URL: " REGISTRY_PASSWORD
        if [ "$REGISTRY_PASSWORD" == "" ]; then
        echo ""
            echo "Cannot proceed without REGISTRY_PASSWORD.  Bailing..."
            exit
        fi
    fi

    echo "complete"
    echo ""
}

function check_dependencies {
    echo ""
    echo -n "Checking Dependencies..."

    CHECK_INSTALLED="$(command -v direnv)"
    if [ "$?" == "1" ]; then
        echo ""
        echo "Direnv is not installed."
        echo ""
        echo "Direnv is recommended to keep your environment secrets scoped to only this folder."
        read -p "Would you like to setup Direnv? [y/N]: " SETUP_DIRENV
        echo ""

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

    echo "complete"
    echo ""
    # * Worth setting up Harbor
    # * Batteries included Docker Hub is convenient

    # openssl s_client -showcerts -servername hub.docker.com -connect hub.docker.com:443 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $CERTFILE

    # We can check if certs cover the domain
    # openssl crl2pkcs7 -nocrl -certfile mycertificate.cer | openssl pkcs7 -print_certs -noout
 }
