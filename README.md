# Dependencies

[Taskfile](https://taskfile.dev/usage/)
```bash
brew install go-task/tap/go-task
```

[docker](https://docs.docker.com/desktop/setup/install/mac-install/)

kubectl
```
brew install kubectl
```

kind
```bash
brew install kind
```

[kpack cli](https://github.com/buildpacks-community/kpack-cli)
```
brew tap buildpacks-community/kpack-cli
brew install kp
```

## Usage

Create a kind cluster and get local kubeconfig
```bash
task up
```

Delete the kind cluster
```bash
task down
```

## Kpack
[TUTORIAL with setup](https://github.com/buildpacks-community/kpack/blob/main/docs/tutorial.md)

Create a [Docker PAT](https://app.docker.com/settings/personal-access-tokens) for the registry password.
```
kubectl create secret docker-registry registry-credentials \
    --docker-username=my-username \
    --docker-password=my-docker-pat \
    --docker-server=https://index.docker.io/v1/ \
    --namespace kpack
```

Creat a service account to use the credentials
```
kubectl apply -f ./setup/kpack/serviceaccount.yaml
```

Update [builder.yaml](./setup/kpack/builder.yaml) with correct tag of your Docker repo and apply
```
kubectl apply -f ./setup/kpack/builder.yaml
```

## Deploy example app
Build the image with Kpack

Update [image.yaml](./example-app/image.yaml) with correct tag of your Docker repo and apply
```
kubectl apply -f example-app/image.yaml
```

Watch build logs with kp cli
```
kp build logs spring-petclinic-image
```

Deploy application
```
kubectl apply -f example-app/deployment.yaml
```

Port forward service
```
kubectl port-forward service/spring-petclinic-service -n my-namespace 30080:80
```