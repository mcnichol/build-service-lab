#!/usr/bin/env bash

function check_setup_dependencies {
    echo ""
    echo -n "Checking Setup Dependencies..."

    CHECK_INSTALLED="$(command -v direnv)"
    if [ "$?" == "1" ]; then
        echo ""
        echo "Direnv is not installed."
        echo ""
        echo "Direnv is recommended to keep your environment secrets scoped to only this folder."
        read -p "Would you like to setup Direnv? [y/N]: " SETUP_DIRENV
        echo ""

        if [ "${SETUP_DIRENV:0:1}" == "y" ]; then
            if [ "$(uname)" == "Linux" ]; then
                sudo apt install direnv -y
            else
                brew install direnv
            fi

            echo "PATH_add bin" > "$SCRIPT_DIR/.envrc"
            echo 'echo ".envrc file was setup in $(pwd)/.envrc"' >> "$SCRIPT_DIR/.envrc"
            echo 'echo "Add environment variables to me!"' >> "$SCRIPT_DIR/.envrc"

            if [ "$SHELL" == "/bin/zsh" ]; then
                echo "To finish direnv setup execute:"
                echo "  echo 'eval \"\$(direnv hook zsh)\"' >> ~/.zshrc && source ~/.zshrc"
                echo ""
            elif [ "$SHELL" == "/bin/bash" ]; then
                echo ""
                echo "To finish direnv setup execute:"
                echo "  echo 'eval \"\$(direnv hook bash)\"' >> ~/.bashrc && source ~/.bashrc"
            else
                echo "Check docs for setting up hooks in your shell: https://direnv.net/"
            fi

            echo ""
            echo "Once hook is set create .envrc file to export environment variables scoped to this folder"
            echo ""
            echo "Execute command:"
            echo "  touch .envrc && direnv allow"
            exit
        fi
    fi

    echo "complete"
    echo ""
}

function check_variables {
    echo ""
    echo -n "Checking for required variables..."

    if [ -z "$PIVOTAL_AUTH_TOKEN" ];then
        echo ""
        echo "Login to https://network.pivotal.io and navigate to Username > Edit Profile > User Profile > Legacy API Token"
        echo ""
        echo "PIVOTAL_AUTH_TOKEN required for downloading pb, duffle, and build-dependences from Pivnet"
        echo "Consider adding \`export PIVOTAL_AUTH_TOKEN=\"YOUR_TOKEN\"\` to .envrc"
        echo ""
        read -s -p "Please enter your Pivotal Auth Token: " PIVOTAL_AUTH_TOKEN
        if [ "$PIVOTAL_AUTH_TOKEN" == "" ]; then
            echo ""
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
            echo ""
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
            echo ""
            echo "Cannot proceed without REGISTRY_PATH.  Bailing..."
            exit
        fi
    fi

    if [ -z "$REGISTRY_PASSWORD" ];then
        echo ""
        echo "REGISTRY_PASSWORD required for Authenticating to registry"
        echo "Consider adding \`export REGISTRY_PASSWORD=\"password\"\` to .envrc"
        echo ""
        read -s -p "Please enter the password for $REGISTRY_URL: " REGISTRY_PASSWORD

        if [ "$REGISTRY_PASSWORD" == "" ]; then
            echo ""
            echo "Cannot proceed without REGISTRY_PASSWORD.  Bailing..."
            exit
        fi
    fi

    if [ -z "$CLUSTER_NAME" ];then
        echo ""
        echo "CLUSTER_NAME required for naming clusters"
        echo "Consider adding \`export CLUSTER_NAME=\"my-cluster-name\"\` to .envrc"
        echo ""
        read -p "Please enter the cluster name: " CLUSTER_NAME

        if [ "$CLUSTER_NAME" == "" ]; then
            echo ""
            echo "Cannot proceed without CLUSTER_NAME.  Bailing..."
            exit
        fi
    fi

    if [ -z "$DUFFLE_CLAIM" ];then
        echo ""
        echo "DUFFLE_CLAIM required for installing Build Service"
        echo "Consider adding \`export DUFFLE_CLAIM=\"my-duffle-claim\"\` to .envrc"
        echo ""
        read -p "Please enter the duffle claim name: " DUFFLE_CLAIM

        if [ "$DUFFLE_CLAIM" == "" ]; then
            echo ""
            echo "Cannot proceed without DUFFLE_CLAIM.  Bailing..."
            exit
        fi
    fi

    echo "complete"
    echo ""
}

function check_dependencies {
    echo ""
    echo -n "Checking Dependencies..."

    if [ ! -d "$SCRIPT_DIR/bin" ]; then
        echo ""
        echo -n "./bin folder missing for cli binaries. creating..."
        mkdir "$SCRIPT_DIR/bin"
        echo "created.  This folder is .gitignore'd and not version controlled."
    fi

    if [ ! -d "$SCRIPT_DIR/tmp" ]; then
        echo ""
        echo -n "./tmp folder missing for build-service dependencies. creating..."
        mkdir "$SCRIPT_DIR/tmp"
        echo "created.  This folder is .gitignore'd and not version controlled."
    fi

    if [ ! -d "$SCRIPT_DIR/config" ]; then
        echo ""
        echo -n "./config folder missing for sensitive config credentials. creating..."
        mkdir "$SCRIPT_DIR/config"
        echo "created.  This folder is .gitignore'd and not version controlled."
    fi

    # duffle
    CHECK_INSTALLED="$(command -v duffle)"
    if [ "$?" == "1" ]; then
        if [ "$(uname)" == "Linux" ]; then
            echo "Downloading duffle-cli for Linux"
            curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648382/download -o $SCRIPT_DIR/bin/duffle --progress
            chmod 755 $SCRIPT_DIR/bin/duffle
        else
            echo "Downloading duffle-cli for Mac"
            curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648381/download -o $SCRIPT_DIR/bin/duffle --progress
            chmod 755 $SCRIPT_DIR/bin/duffle
        fi
    fi

    CHECK_INSTALLED="$(command -v pb)"
    if [ "$?" == "1" ]; then
        if [ "$(uname)" == "Linux" ]; then
            echo "Downloading pb-cli for Linux"
            curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648385/download -o $SCRIPT_DIR/bin/pb --progress
            chmod 755 $SCRIPT_DIR/bin/pb
        else
            echo "Downloading pb-cli for Mac"
            curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648384/download -o $SCRIPT_DIR/bin/pb --progress
            chmod 755 $SCRIPT_DIR/bin/pb
        fi

    fi

    CHECK_INSTALLED="$(ls $SCRIPT_DIR/tmp/build-service-0.1.0.tgz > /dev/null 2>&1)"
    if [ "$(( $? > 0))" == "1" ]; then
        echo "Downloading build-service-0.1.0"
        curl -L -H "Authorization: Token $PIVOTAL_AUTH_TOKEN" https://network.pivotal.io/api/v2/products/build-service/releases/612454/product_files/648378/download -o "$SCRIPT_DIR/tmp/build-service-0.1.0.tgz" --progress
    fi

    echo "complete"
    echo ""
}
