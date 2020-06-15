# Introduction

Hosting many teams on a single cluster

## Contents

* base
  * arm - ARM assets
  * yaml - yaml files
* clusters - clusters and resources to be deployed to respective cluster
  * demo - contains SCC and resources for Scenario
* scripts - helper scripts:
  * This repo contains a script to configure a new tenant. Run `./configure-tenant.sh --help` for usage.

## Getting Started

You will need...

* at least one connected cluster, PROD_CLUSTER_NAME. Optionally a second cluster for dev
* a SUB_ID, the azure subscription of connected cluster
* a ARC_RG, the azure resource group of connected cluster

1. Fork/clone this repository
1. Run the following where `REPO` is the ssh path of your newly forked repo

    ```sh
    # Dedicate tenant space on Prod cluster
    ./scripts/configure-tenant.sh --repo $REPO \
        --cluster $PROD_CLUSTER_NAME --arc-rg $ARC_RG \
        --subscriptionId $SUB_ID --tenant team-1 \
        --tenant-git git@github.com:vyta/azure-voting-gitops-demo.git --tenant-git-path prod \
        --deploy

    # Optional: Dedicate tenant space on Dev cluster
    ./scripts/configure-tenant.sh --repo $REPO \
        --cluster $DEV_CLUSTER_NAME --arc-rg $ARC_RG \
        --subscriptionId $SUB_ID --tenant team-1 \
        --tenant-git git@github.com:vyta/azure-voting-gitops-demo.git --force --tenant-git-path dev \
        --deploy
    ```

1. Grab ssh key:
  
    ```sh
    # Using az cli
    az k8sconfiguration show -g $ARC_RG -c $PROD_CLUSTER_NAME -n $PROD_CLUSTER_NAME-base-config --cluster-type connectedClusters

    # Using kubectl
    kubectl get gitconfig $PROD_CLUSTER_NAME-base-config -n cluster
    ```

1. Git push to master of forked repo
1. Observe resources on cluster via kubectl: `kubectl get all -n team-1`

## configure-tenant.sh

Configuring a tenant will scaffold a dedicated directory to house tenant specific k8s resources:

* namespace.yaml
* Tenant sourceControlConfiguration, and create the SCC in azure

The script will also create cluster specific resources:

* Base sourceControlConfiguration parameters, and create the SCC in azure.

Workflow:

* Cluster operator configures a dedicated namespace and other basline configuration including SCC instance for a given tenant.
* SCC is configured to point to the Tenant's repo: [azure-voting-gitops-demo](https://github.com/vyta/azure-voting-gitops-demo) in this case
