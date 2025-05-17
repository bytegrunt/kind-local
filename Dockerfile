FROM alpine:latest

RUN apk add --no-cache \
  bash curl git jq bash-completion docker-cli && \
  mkdir -p /etc/bash_completion.d

# Define tool versions
ARG KUBECTL_VERSION=1.33.0
ARG HELM_VERSION=3.17.3
ARG KIND_VERSION=0.27.0
ARG TERRAFORM_VERSION=1.12.0
ARG YQ_VERSION=4.45.4

# inject the target architecture (https://docs.docker.com/reference/dockerfile/#automatic-platform-args-in-the-global-scope)
ARG TARGETARCH

# install kubectl
RUN curl -fsSL "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/$TARGETARCH/kubectl" > /tmp/kubectl && \
  install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl && \
  kubectl completion bash > /etc/bash_completion.d/kubectl && \
  rm /tmp/kubectl

# install helm (https://github.com/helm/helm/releases)
RUN mkdir /tmp/helm && \
  curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz > /tmp/helm/helm.tar.gz && \
  tar -zxvf /tmp/helm/helm.tar.gz -C /tmp/helm && \
  install -o root -g root -m 0755 /tmp/helm/linux-${TARGETARCH}/helm /usr/local/bin/helm && \
  helm completion bash > /etc/bash_completion.d/helm && \
  rm -rf /tmp/helm

# install kind https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries
RUN curl -fsSL https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-${TARGETARCH} > /tmp/kind && \
  install -o root -g root -m 0755 /tmp/kind /usr/local/bin/kind && \
  rm /tmp/kind

# install yq
RUN  curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${TARGETARCH} > /tmp/yq && \
  install -o root -g root -m 0755 /tmp/yq /usr/local/bin/yq && \
  yq shell-completion bash > /etc/bash_completion.d/yq && \
  rm /tmp/yq

# Add a step to download the ArgoCD manifest
RUN curl -fsSL https://raw.githubusercontent.com/argoproj/argo-cd/master/manifests/install.yaml -o argocd-install.yaml

ENV KUBECONFIG="/state/kube/config-internal.yaml"

COPY . /app

WORKDIR /app

ENTRYPOINT ["/bin/bash"]
