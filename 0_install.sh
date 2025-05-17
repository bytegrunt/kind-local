#!/usr/bin/env bash
set -eo pipefail

mkdir -p /state/kube

if ! kind get clusters | grep -q "^kind$"; then
  kind create cluster -n kind --kubeconfig /state/kube/config.yaml --config ./setup/kind/cluster.yaml
fi

container_name="kind-cluster-setup"
docker network connect "kind" "${container_name}"

kubeconfig_docker=/state/kube/config-internal.yaml
kind export kubeconfig --internal  --kubeconfig "$kubeconfig_docker"

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version 4.12.2 \
  --values ./setup/helm/ingress-nginx.yaml \
  --kubeconfig "$kubeconfig_docker"

kubectl apply -f ./setup/namespaces/namespaces.yaml 
kubectl apply -f /argocd-install.yaml -n argocd
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
kubectl apply -f ./setup/argocd/ingress.yaml
kubectl apply -f ./setup/kpack/kpack-release-0.17.0.yaml ./setup/kpack/stack.yaml ./setup/kpack/store.yaml ./setup/kpack/lifecycle.yaml

echo ""
echo ">>>> Everything prepared, ready to deploy application."
echo ">>>>"
echo ">>>> To access ArgoCD UI, use the following command:"
echo ">>>> https://localhost:30443"
echo ">>>> username: admin"
echo ">>>> password: $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d)"
