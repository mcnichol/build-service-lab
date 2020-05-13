# Build Service Demo Client

## Goals
This tool is meant to help you setup the Build Service for a possible Demo/PoC and hopefully connect a few points of understanding along the way. 

The aim is to get you as close to the underlying tooling to understand which pieces do what, understand the goals of Build Service, and provide a starting point to offer criticisms to the teams upstream.

There are a few loosely coupled dependencies in this system. I am going to recommend a couple more that will hopefully make your productivity workflow easier. The primary one being [direnv](https://direnv.net/) which I cannot recommend highly enough. Use it and unload some of the mental configuration burden. In the early stages there are several moving parts for you to reason about, this will prevent you from tripping over your own configuration.

## Requirements
Build Service runs on Kubernetes. This tool can provide a Kubernetes Cluster. It currently works with GKE. It's goals are ambitious in providing and installing to every cluster. Bash Scripting has been chosen as an accessible language for any Architect to intuit what is happening in the steps of wiring these tools together.  

Currently supported cluster creation:
- GKE

In Progress:
- PKS
- EKS
- AKS
- KIND

## Setup

1. Clone this repo:  
```
git clone https://github.com/mcnichol/build-service-lab.git && cd build-service-lab
```
1. If using [direnv](https://direnv.net/) we will setup an .envrc file in the root of this repo which will export required environment variables. If not using Direnv initialize and export the variables found in etc/envrc.template
    1. On Mac install Direnv 
    ```
    brew install direnv
    ```
    1. Follow the instructions for adding the direnv hook to your shell rc file
    1. Copy etc/envrc.template to repo root .envrc 
    ```
    cp etc/envrc.template .envrc
    ```
    1. Edit the environment variables in .envrc with your values. Some lines will need to be uncommented depending on Kubernetes Cluster needs
    1. Allow variables to be exported 
    ```
    direnv allow
    ``` 
1. Create your cluster and install build service
```
./pbsetup create gke-cluster
```

You now have a Cluster with Tanzu Build Service! To query your cluster you can use the kubeconfig that you created. 
```
KUBECONFIG=config/kubeconfig.yaml kubectl get all
```

*Note: If you are using GKE, the Service Account we created is required as well.*
```
GOOGLE_APPLICATION_CREDENTIALS=config/$CLUSTER_NAME-sa.json KUBECONFIG=config/kubeconfig.yaml kubectl get all
```

## Use the Cluster
Let's do something with our Build Service
