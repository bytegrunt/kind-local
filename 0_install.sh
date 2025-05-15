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

echo ""
echo ">>>> Everything prepared, ready to deploy application."
