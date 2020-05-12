#!/usr/bin/env bash

function gcloud_check_envvar(){
    if [ -z "$GCLOUD_PROJECT_ID" ]; then
        echo ""
        echo "When using GKE you must specify a Project ID"
        echo ""
        echo "You can get your Project ID by running:"
        echo "   gcloud auth list --filter=status:Active --format='value(account)'"
        echo ""
        read -p "Please enter your Project ID (e.g. fe-USERNAME): " GCLOUD_PROJECT_ID

        if [ -z "$GCLOUD_PROJECT_ID" ]; then
            echo "Cannot proceed without a Project ID.  Bailing..."
            echo ""
            echo "Learn more about Google Project ID's here: https://cloud.google.com/sdk/gcloud/reference/projects"
            exit
        fi
    fi

    if [ -z "$GCLOUD_ZONE" ]; then
        echo ""
        echo "When using GKE you must target a Zone"
        echo ""
        read -p "Please enter your the Zone for your environment (e.g. us-central1-c): " GCLOUD_ZONE

        if [ -z "$GCLOUD_ZONE" ]; then
            echo "Cannot proceed without a Zone.  Bailing..."
            echo ""
            echo "Learn more about Google Zones here: https://cloud.google.com/compute/docs/regions-zones"
            exit
        fi
    fi
}

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

function gcloud_create_kubeconfig(){

    echo "Creating KUBECONFIG for $CLUSTER_NAME stored in $SCRIPT_DIR/config"
    sleep 2s

    CLUSTER_IP="$(gcloud container clusters describe $CLUSTER_NAME --zone=$GCLOUD_ZONE --format='value(endpoint)')"
    CLUSTER_CA="$(gcloud container clusters describe $CLUSTER_NAME --zone=$GCLOUD_ZONE --format='value(masterAuth.clusterCaCertificate)')"

cat > $SCRIPT_DIR/config/kubeconfig.yaml <<EOF
apiVersion: v1
kind: Config
current-context: pbs-cluster-context
contexts: [{name: pbs-cluster-context, context: {cluster: $CLUSTER_NAME, user: gcp-user}}]
users: [{name: gcp-user, user: {auth-provider: {name: gcp}}}]
clusters:
- name: $CLUSTER_NAME
  cluster:
    server: "https://$CLUSTER_IP"
    certificate-authority-data: "$CLUSTER_CA"
EOF
}

function gcloud_create_service_account(){
  echo "Creating Google Cloud Service Account $GCLOUD_SERVICE_ACCOUNT for Accessing Cluster"
  sleep 2s

  CHECK_ACCOUNT_EXISTS=$(gcloud iam service-accounts describe $GCLOUD_SERVICE_ACCOUNT@$GCLOUD_PROJECT_ID.iam.gserviceaccount.com)
  if [ "$?" == "1" ]; then
      gcloud iam service-accounts create $GCLOUD_SERVICE_ACCOUNT
      gcloud projects add-iam-policy-binding $GCLOUD_PROJECT_ID --member "serviceAccount:$GCLOUD_SERVICE_ACCOUNT@$GCLOUD_PROJECT_ID.iam.gserviceaccount.com" --role "roles/owner"
  fi

  gcloud iam service-accounts keys create "$SCRIPT_DIR/config/$GCLOUD_SERVICE_ACCOUNT.json" --iam-account $GCLOUD_SERVICE_ACCOUNT@$GCLOUD_PROJECT_ID.iam.gserviceaccount.com

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
        echo ""
    fi
}

gcloud_check_envvar
