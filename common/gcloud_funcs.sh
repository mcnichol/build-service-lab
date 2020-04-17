#!/usr/bin/env bash

function gcloud_guard(){
    gcloud_check_cli
    gcloud_login_check
}

function gcloud_login_check(){
    GCLOUD_CURRENT_AUTHENTICATED="$(gcloud auth list --filter=status:ACTIVE --format='value(account)')"

    if [ -z $GCLOUD_CURRENT_AUTHENTICATED ]; then
        gcloud auth login
    else
        echo ""
        echo "Currently logged in with: $GCLOUD_CURRENT_AUTHENTICATED"
        echo ""
        echo "To logout execute:"
        echo -e "\tgcloud auth revoke $GCLOUD_CURRENT_AUTHENTICATED"
        echo ""
    fi
}

function gcloud_check_cli(){
    echo ""
    echo -n "Checking for gcloud cli..."

    CHECK_INSTALLED="$(command -v gcloud)"
    if [ "$?" == "1" ]; then
        echo "not installed."
        echo ""
        echo "gcloud is required to setup GKE from the terminal."
        read -p "Would you like to install gcloud cli? [y/N]: " SETUP_GCLOUD_CLI
        echo ""

        if [ "${SETUP_GCLOUD_CLI:0:1}" == "y" ]; then
            brew cask install google-cloud-sdk
        else
            echo ""
            echo "Cannot continue installing GKE Cluster from terminal.  Bailing..."
            echo "Visit: https://cloud.google.com/sdk/gcloud for help on manually installing"
            exit
        fi
    else
        echo "installed"
        echo ""1
    fi
}
