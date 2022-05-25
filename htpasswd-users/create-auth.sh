#!/usr/bin/bash

USERS_HTPASSWD_SECRET="htpasswd-secret"
HTPASSWD_FILE="./users.htpasswd"
KUBECONFIG=$1
USER1="ocadmin"

oc --kubeconfig ${KUBECONFIG} create secret generic ${USERS_HTPASSWD_SECRET} --from-file=htpasswd=${HTPASSWD_FILE} -n openshift-config

oc --kubeconfig ${KUBECONFIG} apply -f - <<EOF
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: httpasswd_idp
    challenge: true
    login: true
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: ${USERS_HTPASSWD_SECRET}
EOF

sleep 10s

oc adm policy add-cluster-role-to-user cluster-admin ${USER1} --rolebinding-name=cluster-admin --kubeconfig ${KUBECONFIG}
