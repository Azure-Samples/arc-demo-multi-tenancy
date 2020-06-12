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

* a connected cluster, CLUSTERNAME
* a SUBID, the azure subscription of connected cluster
* a ARCRG, the azure resource group of connected cluster

1. Fork/clone this repository
1. Run the following

    ```bash
    ./scripts/configure-tenant.sh --cluster CLUSTERNAME \
        --tenant custom-a --app azure-voting \
        --subscriptionId $SUBID \
        --arc-rg $ARCRG \
        --deploy
    ```

1. Git push to master to observe changes on cluster

## configure-tenant.sh

Scaffolds tenant specific resources based on baseline configuration
