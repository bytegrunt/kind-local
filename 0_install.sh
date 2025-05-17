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

kubectl apply -f ./setup/argocd/install.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n default --timeout=120s
kubectl apply -f ./setup/argocd/ingress.yaml

echo ""
echo ">>>> Everything prepared, ready to deploy application."
echo ">>>>"
echo ">>>> To access ArgoCD UI, use the following command:"
echo ">>>> https://localhost:30443"
echo ">>>> username: admin"
echo ">>>> password: $(kubectl get secret argocd-initial-admin-secret -n default -o jsonpath='{.data.password}' | base64 --decode)"



