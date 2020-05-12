# Build Service Demo Client
This tool is meant to get you setup with Build Service and hopefully provide a few points of understanding along the way. 

The aim is to get you as close to the underlying tooling enabling you to understand the underlying tooling, its goals, and offer criticisms to the teams upstream.

Setting this up leverages a few tools meant to simplify the "dependencies" you must to be aware of in addition to a centralized place for all configurations that is automatically loaded into your environment. This leverages [direnv](https://direnv.net/) which I cannot recommend highly enough. Use it and unload some mental burden as in the early stages, there are still many moving parts for you to reason about.

## Requirements
Build Service runs on Kubernetes. This tool can provide a Kubernetes Cluster. It currently works with GKE. It's goals are ambitious in possibly providing and working with every cluster. Bash Scripting has been chosen as an accessible language for any Architect to intuit what is happening in the steps of wiring these disparate tools.  

Currently supported cluster creation:
- GKE

In Progress:
- PKS
- EKS
- AKS
- KIND

## Setup

1. Clone this repo: `git clone https://github.com/mcnichol/build-service-lab.git && cd build-service-lab`
1. If using [direnv](https://direnv.net/) setup an .envrc file in root directory exporting required environment variables. Otherwise initialize and export the variables found in etc/envrc.template
    1. If on Mac you can install direnv with `brew install direnv`
    1. You can find a template .envrc file with all necessary variables in ${GITHUB_ROOT}/etc/envrc.template: `cp etc/envrc.template .envrc`
    1. Edit these files with your values. Some lines will need to be uncommented depending on Kubernetes Cluster needs
    1. Allow the export of variables in the local .envrc file: `direnv allow` 
1. Create your cluster and install build service: `./pbsetup create gke-cluster`
