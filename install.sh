#!/bin/bash

set -e

TILLER_NAMESPACE=tiller-namespace
export TILLER_NAMESPACE

PROJECT=$(oc project --short)
export PROJECT

if [[ -z "$SOURCE_REPOSITORY_URL" ]]; then
    >&2 "ERROR please set env var SOURCE_REPOSITORY_URL"
    exit 1
fi

OPENSHIFT_SERVER=$(oc project |  awk '{
  str = $NF
  gsub(/"/, "", str)
  sub(/.$/, "", str)  
  print str
}')
export OPENSHIFT_SERVER

helm upgrade --install --debug \
    --set "openshiftServer=${OPENSHIFT_SERVER},project=${PROJECT},source_repository_url=${SOURCE_REPOSITORY_URL},s2iimage=nodejs-8-rhel7,insecureSkipTlsVerify=true,webhookRepFullname=simbo1905/realworld-react-redux,buildNamespace=${PROJECT},name=realworld-${PROJECT}" \
    realworld \
    ocd-release-build

SECRET_NAME=$(
    oc describe sa sa-tag-realworld-${PROJECT} |
    awk -F': *' '
        $2  { KEY=$1 ; VALUE=$2;  }
        !$2 {          VALUE=$1; }
        KEY=="Mountable secrets" && VALUE !~ /docker/ { gsub(/^[ \t]+/, "", VALUE);print VALUE }
    '
)
echo "SECRET_NAME=$SECRET_NAME"
oc patch -n "$PROJECT" "bc/tag-realworld-${PROJECT}" -p "$(
cat <<EOF
{
    "spec": {
        "source": {
            "secrets": [
                {
                    "secret": {
                        "name": "$SECRET_NAME"
                    },
                    "destinationDir": "/sa-secret-volume"
                }
            ]
        }
    }
}
EOF
)"