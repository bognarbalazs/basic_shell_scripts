#!/bin/sh

K8S_CLUSTER="<cluster_name>"
K8S_CONTEXT="k8s-${K8S_CLUSTER}"
K8S_API_URL="<api_url>"
K8S_API_CA_FILE="k8s-ca-${K8S_CLUSTER}.pem"
K8S_OIDC_ISSUER_URL="<oidc_issuer_url>"
K8S_OIDC_CRED="oidc@${K8S_CLUSTER}"
K8S_OIDC_CLIENT_ID="<oidc_client_id>"
K8S_OIDC_CLIENT_SECRET="<oidc_client_secret>"


echo "-----BEGIN CERTIFICATE-----
asdsadsad
-----END CERTIFICATE-----
" \ > "${K8S_API_CA_FILE}"

kubectl config set-cluster "${K8S_CLUSTER}" --server=${K8S_API_URL} --certificate-authority="${K8S_API_CA_FILE}" --embed-certs
kubectl config set-credentials ${K8S_OIDC_CRED} \
  --exec-api-version=client.authentication.k8s.io/v1beta1 \
  --exec-command=kubectl \
  --exec-arg=oidc-login \
  --exec-arg=get-token \
  --exec-arg=--oidc-issuer-url=${K8S_OIDC_ISSUER_URL} \
  --exec-arg=--oidc-client-id=${K8S_OIDC_CLIENT_ID} \
  --exec-arg=--oidc-client-secret=${K8S_OIDC_CLIENT_SECRET}
kubectl config set-context "${K8S_CONTEXT}" --cluster="${K8S_CLUSTER}" --user="${K8S_OIDC_CRED}"
kubectl config use-context "${K8S_CONTEXT}"

rm ${K8S_API_CA_FILE}
