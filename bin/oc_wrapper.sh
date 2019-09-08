#!/bin/bash

# try assuming our previous login hasn't timed out
if ! oc "${INSECURE_SKIP_TLS_VERIFY}" "$@" 2>/dev/null; then
    # if it didn't work assume that we have yet to login or it timed out

    # do login
    if ! oc login "${INSECURE_SKIP_TLS_VERIFY}" \
            "${OPENSHIFT_SERVER}" \
            --certificate-authority='/var/run/secrets/kubernetes.io/serviceaccount/ca.crt' \
            --token="$(< /var/run/secrets/kubernetes.io/serviceaccount/token)" ; then
        (>&2 echo "ERROR Could not oc login. Exiting")
        exit 3
    fi

    #try again
    oc "${INSECURE_SKIP_TLS_VERIFY}" "$@"
fi
