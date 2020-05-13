# Build Service Demo Client

## Goals
This tool is meant to help you setup the Build Service for a possible Demo/PoC and hopefully connect a few points of understanding along the way. 

We stay close to the underlying tooling to understand which pieces play what role, understand the goals of Build Service, and provide a feedback loop of thoughts to development teams. One of the most important things we can do is incorporate the reality of what we are seeing and hearing with the future of what Build Service becomes.

There are a few loosely coupled dependencies in this system (Duffle, pb cli, Image Registry, KPack, K8S cli) in addition to the Build Service itself. I am going to recommend a couple more that will hopefully make your productivity workflow easier. The primary one being [direnv](https://direnv.net/) which I cannot recommend highly enough. Use it and unload some of the mental configuration burden.

## Requirements
Build Service runs on Kubernetes. This tool not only installs Build Service but can provide the Kubernetes Cluster as well. It currently works with GKE. It's goals are ambitious in providing and installing to every cluster. Bash Scripting has been chosen as an accessible language for any Architect to intuit what is happening in the wiring and translate to a pipeline or alternative language.  

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
1. Using [direnv](https://direnv.net/) we will setup an .envrc file in the root of this repo which will export required environment variables.
    * Install Direnv 
        * Mac: `brew install direnv`
        * Linux: `sudo apt install direnv`
    * Add the direnv hook to your shell's rc file. (e.g. `echo 'eval "$(direnv hook bash)"' >> ~/.bashrc`)
    * Copy envrc.template to repo root as .envrc 
    ```
    cp etc/envrc.template .envrc
    ```
    * Edit the environment variables in `.envrc` with your values. Some lines will need to be uncommented depending on which Kubernetes Cluster you are using 
    * Allow variables to be exported 
    ```
    direnv allow
    ``` 
**Note: If you choose not to use Direnv**  
Copy etc/envrc.template to the root of this directory as .envrc.  Edit the values and source this file to your current session. .envrc is gitignore'd so will not be tracked.
1. Create your cluster and install build service
```
./pbsetup create gke-cluster
```

You now have a Cluster with Tanzu Build Service! To query your cluster you can use the kubeconfig created in the config/ directory. 
```
KUBECONFIG=config/kubeconfig.yaml kubectl get all
```

*Note: If you are using GKE, the Service Account we created is required as well.*
```
GOOGLE_APPLICATION_CREDENTIALS=config/$CLUSTER_NAME-sa.json KUBECONFIG=config/kubeconfig.yaml kubectl get all
```

## Use the Cluster
Let's do something with our Build Service
