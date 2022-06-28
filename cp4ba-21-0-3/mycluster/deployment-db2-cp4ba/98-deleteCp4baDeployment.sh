#!/bin/bash
# set -x
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2022. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CP4BA_INPUT_PROPS_FILENAME="05-parametersForCp4ba.sh"
CP4BA_INPUT_PROPS_FILENAME_FULL="${CUR_DIR}/${CP4BA_INPUT_PROPS_FILENAME}"

if [[ -f $CP4BA_INPUT_PROPS_FILENAME_FULL ]]; then
   echo
   echo "Found ${CP4BA_INPUT_PROPS_FILENAME}.  Reading in variables from that script."
   . $CP4BA_INPUT_PROPS_FILENAME_FULL
   
   if [[ $cp4baProjectName == "" ]]; then
      echo "File ${CP4BA_INPUT_PROPS_FILENAME} not updated. Pls. update."
      echo
      exit 0
   fi

   echo "Done!"
else
   echo
   echo "File ${CP4BA_INPUT_PROPS_FILENAME_FULL} not found. Pls. check."
   echo
   exit 0
fi

echo
echo -e "\x1B[1mThis script DELETES the current CP4BA deployment (ibm_cp4a_cr_final.yaml) in project ${cp4baProjectName}. \n \x1B[0m"

printf "Do you want to continue (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Deleting the current CP4BA deployment..."
    ;;
*)
    echo
    echo -e "Exiting..."
    echo
    exit 0
    ;;
esac

echo
echo "Switching to project ${cp4baProjectName}..."
oc project $cp4baProjectName

echo
echo "Deleting the current deployment..."
oc delete -f ibm_cp4a_cr_final.yaml
sleep 120

echo
echo "Deleting the PVCs..."
oc delete pvc icn-asperastore
oc delete pvc icn-cfgstore
oc delete pvc icn-logstore
oc delete pvc icn-pluginstore
oc delete pvc icn-vw-cachestore
oc delete pvc icn-vw-logstore

oc delete pvc cmis-cfgstore
oc delete pvc cmis-logstore

oc delete pvc cpe-bootstrapstore
oc delete pvc cpe-cfgstore
oc delete pvc cpe-filestore
oc delete pvc cpe-fnlogstore
oc delete pvc cpe-icmrulesstore
oc delete pvc cpe-logstore
oc delete pvc cpe-textextstore

oc delete pvc css-cfgstore
oc delete pvc css-customstore
oc delete pvc css-indexstore
oc delete pvc css-logstore
oc delete pvc css-tempstore

oc delete pvc graphql-cfgstore
oc delete pvc graphql-logstore

oc delete pvc icp4adeploy-bastudio-authoring-jms-data-vc-icp4adeploy-bastudio-authoring-jms-0

oc delete pvc cdra-cfgstore
oc delete pvc cdra-datastore
oc delete pvc cdra-logstore
oc delete pvc cds-logstore
oc delete pvc cpds-cfgstore
oc delete pvc cpds-logstore
oc delete pvc gitgateway-cfgstore
oc delete pvc gitgateway-datastore
oc delete pvc mongo-datastore
oc delete pvc viewone-cacherootstore
oc delete pvc viewone-configstore
oc delete pvc viewone-customerfontsstore
oc delete pvc viewone-docrepositoryrootstore
oc delete pvc viewone-externalresourcepathstore
oc delete pvc viewone-logsstore
oc delete pvc viewone-workingpathstore

oc delete pvc data-icp4adeploy-elasticsearch-statefulset-0
oc delete pvc icp4adeploy-workflow-authoring-baw-jms-data-vc-icp4adeploy-workflow-authoring-baw-jms-0

oc delete pvc data-icp4adeploy-ibm-dba-ek-data-0
oc delete pvc data-icp4adeploy-ibm-dba-ek-data-1
oc delete pvc data-icp4adeploy-ibm-dba-ek-master-0
oc delete pvc data-icp4adeploy-ibm-dba-ek-master-1
oc delete pvc data-icp4adeploy-ibm-dba-ek-master-2
sleep 60

echo
echo "Deleting the secrets..."
oc delete -f secrets.yaml
oc delete -f tlsSecrets.yaml
oc delete secret rpa-secret
oc delete -f adp-aca-basedb-secret.yaml
oc delete secret github-cert
sleep 60

echo
echo "Deleting the operator pod (will be re-created automatically)..."
oc get pods | grep ibm-cp4a-operator- | awk '$1 {print$1}' | while read vol; do oc delete pod/${vol}; done

echo
printf "Do you want to also cleanup all prerequisites (IAF, ZEN, ibm-common-services, ...)? You only should do this if there is no other component deployed that still needs those prerequisites (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Cleaning up all prerequisites..."
    ;;
*)
    echo
    echo -e "Exiting without cleaning up all prerequisites..."
    echo
    exit 0
    ;;
esac

echo
echo "Deleting PVC from project ibm-common-services..."
oc project ibm-common-services
oc delete pvc mongodbdir-icp-mongodb-0
oc project $cp4baProjectName

echo
echo "Deleting all prerequisites..."
# deleting prerequisites according to https://www.ibm.com/docs/en/cloud-paks/1.0?topic=foundation-uninstalling
oc delete AutomationUIConfig iaf-system

oc -n ibm-common-services get csv -o name --ignore-not-found | grep 'ibmcloud-operator' | xargs oc -n ibm-common-services delete  
oc -n ibm-common-services get installplans | grep 'ibmcloud-operator' | awk '{print $1}' | xargs oc -n ibm-common-services delete installplan
oc -n default delete secrets ibmcloud-operator-secret ibmcloud-operator-tokens --ignore-not-found
oc -n default delete configmaps ibmcloud-operator-defaults --ignore-not-found
oc get crd --no-headers | grep -i "ibmcloud" | awk '{print $1}' | xargs -r oc delete crd

oc patch -n $cp4baProjectName rolebinding/admin -p '{"metadata": {"finalizers":null}}'
oc patch -n $cp4baProjectName rolebinding/edit -p '{"metadata": {"finalizers":null}}'
oc patch -n $cp4baProjectName rolebinding/view -p '{"metadata": {"finalizers":null}}'
oc delete rolebinding admin -n $cp4baProjectName --ignore-not-found
oc delete rolebinding edit -n $cp4baProjectName --ignore-not-found
oc delete rolebinding view -n $cp4baProjectName --ignore-not-found
oc patch -n ibm-common-services rolebinding/admin -p '{"metadata": {"finalizers":null}}'
oc patch -n ibm-common-services rolebinding/edit -p '{"metadata": {"finalizers":null}}'
oc patch -n ibm-common-services rolebinding/view -p '{"metadata": {"finalizers":null}}'
oc delete rolebinding admin -n ibm-common-services --ignore-not-found
oc delete rolebinding edit -n ibm-common-services --ignore-not-found
oc delete rolebinding view -n ibm-common-services --ignore-not-found

oc delete operandrequest --all -n $cp4baProjectName
oc delete operandbindinfo --all -n ibm-common-services
oc delete operandrequest --all -n ibm-common-services
oc delete namespacescope --all -n ibm-common-services
oc patch operandbindinfo ibm-licensing-bindinfo --type="json" -p '[{"op": "remove", "path":"/metadata/finalizers"}]' -n ibm-common-services

oc delete subscription --all -n $cp4baProjectName
oc delete csv --all -n $cp4baProjectName

oc delete subscription --all -n ibm-common-services
oc delete csv --all -n ibm-common-services

oc delete deployment --all -n $cp4baProjectName
oc delete services --all -n $cp4baProjectName

oc delete deployment --all -n ibm-common-services
oc delete services --all -n ibm-common-services

oc delete og ibm-cp4a-operator-catalog-group -n $cp4baProjectName
oc delete og ibm-common-services-operators -n ibm-common-services

oc delete --ignore-not-found $(oc get crd -o name | grep "automation.ibm.com" || echo "crd no-automation-ibm")

oc delete apiservice v1beta1.webhook.certmanager.k8s.io
oc delete apiservice v1.metering.ibm.com

echo
printf "Do you want to also delete projects ${cp4baProjectName} and ibm-common-services (Yes/No, default: No): "
read -rp "" ans
case "$ans" in
"y"|"Y"|"yes"|"Yes"|"YES")
    echo
    echo -e "Deleting projects..."
    ;;
*)
    echo
    echo -e "Exiting without deleting projects..."
    echo
    exit 0
    ;;
esac

echo
oc project default
oc delete project $cp4baProjectName
oc delete project ibm-common-services

echo
echo "Done. Exiting..."
echo