#!/bin/bash

# Script to generate a kubeconfig file for Kubernetes Dashboard admin-user

# Variables
SERVICE_ACCOUNT="admin-user"
NAMESPACE="kubernetes-dashboard"
KUBECONFIG_FILE="dashboard-admin.kubeconfig"

# Get the service account token
TOKEN=$(kubectl -n ${NAMESPACE} create token ${SERVICE_ACCOUNT} --duration=87600h)

# Get the current cluster name, server, and certificate
CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_CERT=$(kubectl config view --flatten --minify -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

# Create the kubeconfig file
cat > ${KUBECONFIG_FILE} <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA_CERT}
    server: ${SERVER}
  name: ${CLUSTER_NAME}
contexts:
- context:
    cluster: ${CLUSTER_NAME}
    namespace: ${NAMESPACE}
    user: ${SERVICE_ACCOUNT}
  name: ${SERVICE_ACCOUNT}@${CLUSTER_NAME}
current-context: ${SERVICE_ACCOUNT}@${CLUSTER_NAME}
users:
- name: ${SERVICE_ACCOUNT}
  user:
    token: ${TOKEN}
EOF

echo "Kubeconfig file created: ${KUBECONFIG_FILE}"
echo "You can now upload this file to the Kubernetes Dashboard login page"
echo ""
echo "To test it, run:"
echo "kubectl --kubeconfig=${KUBECONFIG_FILE} get pods -A"