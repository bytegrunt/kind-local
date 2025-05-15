# Dependencies

[Taskfile](https://taskfile.dev/usage/)
```bash
brew install kind
```

[docker](https://docs.docker.com/desktop/setup/install/mac-install/)

kubectl
```
brew install kubectl
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

