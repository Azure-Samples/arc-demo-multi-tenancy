# Introduction

Hosting the same application but different configurations.

## Contents

* base
  * apps - directories used to template a new tenant
  * arm - ARM assets
  * yaml - yaml files
* clusters - clusters and resources to be deployed to respective cluster
  * demo - contains custom configuration of apps defined in base/apps SCC and resources for this scenario
* scripts - helper scripts:
  * This repo contains a script to configure a new tenant. Run `./configure-tenant.sh --help` for usage.

## Scenario 2 - Getting Started

You will need...

* a connected cluster, CLUSTER_NAME
* a SUB_ID, the azure subscription of connected cluster
* a ARC_RG, the azure resource group of connected cluster

1. Fork/clone this repository
1. Run the following where `REPO` is the ssh path of your newly forked repo

    ```bash
    ./scripts/configure-tenant.sh --repo $REPO \
        --cluster $CLUSTER_NAME \
        --tenant custom-a --app azure-voting \
        --subscriptionId $SUB_ID \
        --arc-rg $ARC_RG \
        --deploy
    ```

1. Grab ssh key:
  
    ```sh
    # Using az cli
    az k8sconfiguration show -g $ARC_RG -c $CLUSTER_NAME -n $CLUSTER_NAME-base-config

    # Using kubectl
    kubectl get gitconfig $CLUSTER_NAME-base-config -n cluster
    ```

1. Git push to master of forked repo
1. Observe resources on cluster via kubectl: `kubectl get all -n custom-a`
1. Add another tenant:

    ```sh
    ./scripts/configure-tenant.sh --repo $REPO \
        --cluster $CLUSTER_NAME \
        --tenant custom-b --app azure-voting

    # Push to master
    git push
    ```

## configure-tenant.sh

Scaffolds tenant specific resources based on baseline configuration
