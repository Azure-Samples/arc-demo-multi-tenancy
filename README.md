# Official Microsoft Sample

<!-- 
Guidelines on README format: https://review.docs.microsoft.com/help/onboard/admin/samples/concepts/readme-template?branch=master

Guidance on onboarding samples to docs.microsoft.com/samples: https://review.docs.microsoft.com/help/onboard/admin/samples/process/onboarding?branch=master

Taxonomies for products and languages: https://review.docs.microsoft.com/new-hope/information-architecture/metadata/taxonomies?branch=master
-->

This repo contains sample implementaions of soft multi-tenant scenarios described in this [design doc](./arc-multitenancy-design.md) using Azure Arc for K8s for GitOps enablement.

## Contents

Outline the file contents of the repository. It helps users navigate the codebase, build configuration and any related assets.

| File/folder          | Description                                  |
|----------------------|----------------------------------------------|
| `scenario1`          | Sample for Scenario 1                        |
| `scenario1`          | Sample for Scenario 2                        |
| `CODE_OF_CONDUCT.md` | Microsoft's code of conduct for open source. |
| `README.md`          | This README file.                            |
| `LICENSE`            | The license for the sample.                  |

## Scenarios - Overview

1. Multiple teams in a single cluster

    * Deployment requirements:
        * Need to be able to dedicate namespace or cluster to a tenant
        * Need to provide as much Tenant autonomy as possible without compromising other tenants

1. One team, multiple instances of the same application in a cluster

    * Deployment requirements:
        * Need to deploy different configurations for a single application
        * Need to manage at least `prod` and `dev` versions and environments

## Prerequisites

* Arc connected cluster(s). Find out more information on how to onboard your clusters with Arc here: [Azure Arc for K8s Preview](https://github.com/Azure/azure-arc-kubernetes-preview/blob/master/docs/connect-a-cluster.md)

## Key concepts

* Kubernetes
* GitOps

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
