#!/usr/bin/env bash
set -exo pipefail

kubectl version --client
helm version
kind version
