#! /bin/bash

if [ "$(basename $(pwd))" == "scripts" ]; then
 cd ..
fi

ARMDIR=base/arm
YAMLDIR=base/yaml
APP_DIR=base/apps

DEPLOY=false
FORCE=false


usage () {
  echo "Usage: ./configure-tenant.sh [-c|--cluster CLUSTER_NAME] [-t|--tenant TENANT] [-s|--subscriptionId SUB_ID ] [-g|--arc-rg ARC_RG ] "
  echo "  -c, --cluster            Required: Name of connected cluster"
  echo "  -t, --tenant             Name of tenant"
  echo "  -a, --app                Path to application to application"
  echo "  -g, --arc-rg             Required: Azure resource group of arc connected cluster"
  echo "  -s, --subscriptionId     Required if --deploy is set. Subscription ID of arc connedted cluster"
  echo "  -d, --deploy             Deploys SCC for a given cluster"
  echo "  -f, --force              Overwrites existing resources"
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
    -a|--app)
      APP=$APP_DIR/$2
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

if [ ! -z "$APP" ] && [ ! -e "$APP" ];
then
  echo "Directory $APP not found."
  exit 1
fi

BASE_SCC=$ARMDIR/base-scc.json

[ ! -e "$CLUSTER_DIR" ] && mkdir $CLUSTER_DIR
clusterSCC=$CLUSTER_DIR/$CLUSTER_NAME-scc.json
# Create cluster scoped sourceControlConfig
if [ ! -e $clusterSCC ] || [ "$FORCE" == true ] ; then 
  echo "Creating $CLUSTER_NAME cluster SCC from $BASE_SCC"
  cp $BASE_SCC $clusterSCC
  sed -i -e 's <PATH> '$CLUSTER_DIR' g' $clusterSCC
fi

nsFile=$TENANT_DIR/ns.yaml
# Create TENANT resources based on parameters provided
if [ ! -z "$TENANT" ] ;
then
  echo "Creating $TENANT resources..."
  [ ! -e "$TENANT_DIR" ] && mkdir $TENANT_DIR
  
  # If an application directory is provided, then scaffold items from provided directory
  if [ ! -z "$APP" ];
  then
    echo "Creating kustomized application..."
    CLUSTERKUSTOMIZE=$CLUSTER_DIR/kustomization.yaml
    if [ ! -e $CLUSTERKUSTOMIZE ]; 
    then
      cp $YAMLDIR/kustomization.yaml $CLUSTERKUSTOMIZE
      sed -i -e 's <TENANT> '$TENANT' g' $CLUSTERKUSTOMIZE
    else
      echo "  - ./$TENANT" >> $CLUSTERKUSTOMIZE
    fi
    cp $YAMLDIR/.flux.yaml $CLUSTER_DIR/.flux.yaml
    cp $APP/. $TENANT_DIR -r
    for filename in $TENANT_DIR/*.yaml; do
      sed -i -e 's <TENANT> '$TENANT' g' $filename
    done
  fi

  # If ns.yaml doesn't already exist then create
  if [ ! -e $nsFile ] || [ "$FORCE" == true ]; then 
    cp $YAMLDIR/namespace.yaml $nsFile
    sed -i -e 's <TENANT> '$TENANT' g' $nsFile
  fi
fi

[ "$DEPLOY" == true ] && deploy $CLUSTER_NAME-base-config $clusterSCC
