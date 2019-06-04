# Kubernetes RBAC Testing

Shell scripts for help automating RBAC setup on test Kubernetes clusters

The primary purpose is to create:
- a service account
- a namespace
- RBAC rules that restrict the service account to only read/write to that namespace
- a kubeconfig for the service account

## Usage:

```
$ ./create-restricted-namespace.sh [namespace]
```

## QA

Verified working on
- [Minikube](https://github.com/kubernetes/minikube)
- [KIND (Kubernetes IN Docker)](https://github.com/kubernetes-sigs/kind)
- [Docker For Desktop (Docker for Mac)](https://www.docker.com/products/docker-desktop)

Won't work with:
- [kubeadm-dind-cluster](https://github.com/kubernetes-sigs/kubeadm-dind-cluster) - Configured to use the insecure API endpoint by default
- [microk8s](https://microk8s.io/) - RBAC not enabled by default

## Credits

Thanks to:

- [The Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes and RBAC: Restrict User Access to One Namespace by Jeremie Vallee](https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html)
- [Debugging help from Guillaume Rose](https://github.com/docker/for-mac/issues/3694)

## License

Copyright 2019 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)