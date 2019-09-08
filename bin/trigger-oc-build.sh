#!/bin/bash

# This script :
# - retrieves the commit id from the last image built
# - tag this image with the commit id

set -e # fail fast
set -o pipefail
IFS=$'\n\t'

TAG=$1

echo "OPENSHIFT_SERVER=$OPENSHIFT_SERVER"
echo "BUILD_NAMESPACE=$BUILD_NAMESPACE"
echo "BUILD=$BUILD"
echo "TAG=$TAG"

if [ -z "$OPENSHIFT_SERVER" ]; then
    (>&2 echo "ERROR could not login OPENSHIFT_SERVER not set")
    exit 3
fi
if [ -z "$BUILD_NAMESPACE" ]; then
    (>&2 echo "ERROR could not login BUILD_NAMESPACE not set")
    exit 4
fi
if [ -z "$BUILD" ]; then
    (>&2 echo "ERROR could not login BUILD not set")
    exit 2
fi

if [ -z "$TAG" ]; then
    (>&2 echo "ERROR no git TAG set")
    exit 5
fi

if [ ! -z "$INSECURE_SKIP_TLS_VERIFY" ]; then
    (>&2 echo "WARNING! using $INSECURE_SKIP_TLS_VERIFY")
fi

oc() { 
    oc_wrapper.sh "$@"
}

set -x # debug

# apply the tag to the built image
# if you get forbidden try:
#   oc create role buildpatch --verb=patch --resource=buildconfigs.build.openshift.io  -n ${BUILD_NAMESPACE}
#   oc adm policy add-role-to-user buildpatch ${OPENSHIFT_USER} --role-namespace={BUILD_NAMESPACE} -n {BUILD_NAMESPACE}
oc patch "${INSECURE_SKIP_TLS_VERIFY}" -n "${BUILD_NAMESPACE}" "buildconfigs/${BUILD}" -p '[{"op": "replace", "path": "/spec/source/git/ref", "value": "'$TAG'"}]' --type=json

# start the patched build
# if you get forbidden try:
#   oc create role buildinstantiate --verb=create --resource=buildconfigs.build.openshift.io/instantiate  -n ${BUILD_NAMESPACE}
#   oc adm policy add-role-to-user buildinstantiate ${OPENSHIFT_USER} --role-namespace={BUILD_NAMESPACE} -n {BUILD_NAMESPACE}
oc start-build "${INSECURE_SKIP_TLS_VERIFY}" "${BUILD}" -n "${BUILD_NAMESPACE}"
