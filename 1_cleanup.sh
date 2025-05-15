#!/usr/bin/env bash
set -eo pipefail

kubeconfig_docker=/state/kube/config-internal.yaml

kind delete cluster -n kind

rm -rf /state/kube