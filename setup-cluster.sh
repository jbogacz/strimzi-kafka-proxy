a#!/bin/bash

set -e

CLUSTER_NAME="argocd-cluster"
ARGOCD_NAMESPACE="argocd"

echo "🚀 Setting up Kind cluster with ArgoCD..."

# Check prerequisites
echo "📋 Checking prerequisites..."
for cmd in kind kubectl helm git; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ $cmd is not installed. Please install $cmd first."
        exit 1
    fi
done

# Create kind cluster
echo "🔧 Creating kind cluster: $CLUSTER_NAME"
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "⚠️  Cluster $CLUSTER_NAME already exists. Deleting it first..."
    kind delete cluster --name $CLUSTER_NAME
fi

kind create cluster --name $CLUSTER_NAME --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.31.9
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30443
    hostPort: 30443
    protocol: TCP
  - containerPort: 30080
    hostPort: 30080
    protocol: TCP
- role: worker
  image: kindest/node:v1.31.9
- role: worker
  image: kindest/node:v1.31.9
EOF

# Wait for cluster to be ready
echo "⏳ Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install ArgoCD
echo "🔧 Installing ArgoCD..."
kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD using official manifests
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=Available deployment/argocd-server -n $ARGOCD_NAMESPACE --timeout=300s
kubectl wait --for=condition=Available deployment/argocd-repo-server -n $ARGOCD_NAMESPACE --timeout=300s
kubectl wait --for=condition=Available deployment/argocd-dex-server -n $ARGOCD_NAMESPACE --timeout=300s

# Patch ArgoCD server service to NodePort for easy access
echo "🔧 Configuring ArgoCD server access..."
kubectl patch svc argocd-server -n $ARGOCD_NAMESPACE -p '{"spec":{"type":"NodePort","ports":[{"name":"http","port":80,"protocol":"TCP","targetPort":8080,"nodePort":30443},{"name":"https","port":443,"protocol":"TCP","targetPort":8080}]}}'

# Get ArgoCD admin password
echo "🔑 Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ Kind cluster with ArgoCD setup complete!"
echo ""
echo "📝 Access Information:"
echo "🌐 ArgoCD UI: http://localhost:30443"
echo "👤 Username: admin"
echo "🔑 Password: $ARGOCD_PASSWORD"
echo ""
echo "🔍 Useful commands:"
echo "  kubectl get applications -n argocd"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  kind delete cluster --name $CLUSTER_NAME"
