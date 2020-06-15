#! /bin/bash

if [ "$(basename $(pwd))" == "scripts" ]; then
 cd ..
fi

ARMDIR=base/arm
YAMLDIR=base/yaml

DEPLOY=false
FORCE=false

CLUSTER_ONLY=false
TENANT_ONLY=false

usage () {
  echo "Usage: ./configure-tenant.sh [-r|--repo REPO] [-c|--cluster CLUSTER_NAME] [-t|--tenant TENANT] [-s|--subscriptionId SUB_ID ] [-g|--arc-rg ARC_RG ] [--tenant-git GIT]"
  echo "  -r, --repo               Required: git@github.com:GITUSER/arc-demo-multi-tenancy.git"
  echo "  -c, --cluster            Required: Name of connected cluster"
  echo "  -t, --tenant             Name of tenant"
  echo "      --tenant-git         tenant's git repo (ex: git@github.com:repo/repo)"
  echo "  -a, --app                Path to application to application"
  echo "  -g, --arc-rg             Required: Azure resource group of arc connected cluster"
  echo "  -s, --subscriptionId     Required if --deploy is set. Subscription ID of arc connedted cluster"
  echo "  -d, --deploy             Deploys SCC for a given cluster"
  echo "  -f, --force              Overwrites existing resources"
  echo "  --cluster-only           Perform actions on cluster resources only"
  echo "  --tenant-only            Perform actions on tenant resources only"
}

deploy () {
  CONFIGURATION_NAME=$1
  CONNECTED_CLUSTER_URI=https://management.azure.com/subscriptions/$SUB_ID/resourceGroups/$ARC_RG/providers/Microsoft.Kubernetes/connectedClusters/$CLUSTER_NAME
  CONFIG_URI=$CONNECTED_CLUSTER_URI/providers/Microsoft.KubernetesConfiguration/sourceControlConfigurations/$CONFIGURATION_NAME

  az rest --method PUT --uri ${CONFIG_URI} --uri-parameters api-version=2019-11-01-preview --body @$2 
}

while [[ "$#" -gt 0 ]]
do
  case $1 in
    -r|--repo)
      REPO=$2
      shift 2
      ;;
    -c|--cluster)
      CLUSTER_NAME=$2
      CLUSTER_DIR=clusters/$2
      shift 2
      ;;
    -t|--tenant)
      TENANT=$2
      TENANT_DIR=$CLUSTER_DIR/$2
      shift 2
      ;;
    --tenant-git)
      TENANT_GIT=$2
      shift 2
      ;;
    --tenant-git-path)
      TENANT_GIT_PATH=$2
      shift 2
      ;;
    -g|--arc-rg)
      ARC_RG=$2
      shift 2
      ;;
    -s|--subscriptionId)
      SUB_ID=$2
      shift 2
      ;;
    -d|--deploy)
      DEPLOY=true
      shift
      ;;
    --cluster-only)
      CLUSTER_ONLY=true
      shift
      ;;
    --tenant-only)
      TENANT_ONLY=true
      shift
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      usage
      exit
      ;;
    *)
      echo "Error: Invalid parameter $1. "
      exit 1
      ;;
  esac
done

if [ -z "$CLUSTER_NAME" ] ;
then
  echo "Error: missing arguments. The following arguments are required: [-c|--cluster]"
  usage
  exit 1
fi

if [ "$DEPLOY" == true ];
then
  if [ -z "$SUB_ID" ] || [ -z "$ARC_RG" ];
  then
    echo "Error: Please specify subscription Id and arc resource group for SCC deployment: -s|--subscriptionId SUB_ID -g|--arc-rg"
    usage
    exit 1
  fi
fi


BASE_SCC=$ARMDIR/base-scc.json
TENANT_BASE_SCC=$ARMDIR/tenant-scc.json

[ ! -e "$CLUSTER_DIR" ] && mkdir $CLUSTER_DIR
clusterSCC=$CLUSTER_DIR/$CLUSTER_NAME-scc.json
# Create cluster scoped sourceControlConfig
if [ ! -e $clusterSCC ] || [ "$FORCE" == true ] && [ "$TENANT_ONLY" != true ]; then 
  echo "Creating $CLUSTER_NAME cluster SCC from $BASE_SCC"
  cp $BASE_SCC $clusterSCC
  sed -i -e 's <REPO> '$REPO' g' $clusterSCC
  sed -i -e 's <PATH> '$CLUSTER_DIR' g' $clusterSCC
fi

nsFile=$TENANT_DIR/ns.yaml
# Create TENANT resources based on parameters provided
if [ ! -z "$TENANT" ] && [ "$CLUSTER_ONLY" != true ];
then
  echo "Creating $TENANT resources..."
  [ ! -e "$TENANT_DIR" ] && mkdir $TENANT_DIR
  
  tenantSCC=$TENANT_DIR/$TENANT-scc.json
  # Scaffold TENANT directory with base configuration    
  [ -z "$TENANT_GIT" ] && echo "Error: missing argument: --tenant-git." && exit;
  [ -z "$TENANT_GIT_PATH" ] && echo "Error: missing argument: --tenant-git-path." && exit;
  if [ ! -e $tenantSCC ] || [ "$FORCE" == true ]; then 
    echo "Creating $TENANT SCC... from $TENANT_BASE_SCC to $tenantSCC"
    cp $TENANT_BASE_SCC $tenantSCC
    sed -i -e 's <TENANT> '$TENANT' g' $tenantSCC
    sed -i -e 's <TENANT_URL> '$TENANT_GIT' g' $tenantSCC
    sed -i -e 's <PATH> '$TENANT_GIT_PATH' g' $tenantSCC
  fi

  # If ns.yaml doesn't already exist then create
  if [ ! -e $nsFile ] || [ "$FORCE" == true ]; then 
    cp $YAMLDIR/namespace.yaml $nsFile
    sed -i -e 's <TENANT> '$TENANT' g' $nsFile
  fi
fi

[ "$DEPLOY" == true ] && [ "$TENANT_ONLY" != true ] && deploy $CLUSTER_NAME-base-config $clusterSCC
[ "$DEPLOY" == true ] && [ "$CLUSTER_ONLY" != true ] &&  [ ! -z "$TENANT_GIT" ] && deploy $TENANT-config $tenantSCC
