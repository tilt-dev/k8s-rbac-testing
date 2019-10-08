# Kubernetes RBAC Testing

Shell scripts for help automating RBAC setup on test Kubernetes clusters

The primary purpose is to create:
- a service account
- a namespace
- RBAC rules that restrict the service account to only read/write to that namespace
- RBAC rules that let the service account read Node information
- a kubeconfig for the service account

## Usage:

```
$ ./create-restricted-namespace.sh [namespace]
```

Creates a kubeconfig with a token for authentication. Instructions on how
to use the kubeconfig will be printed to stdout.

Real, production auth systems use short-lived tokens that need to be refreshed
periodically (e.g., aws-iam-authenticator). If you'd like to simulate that flow,
use the `-e` option to create a fake auth script with rotate-able tokens.

```
$ ./create-restricted-namespace.sh -e [namespace]
```

Instructions on how to rotate the token will be printed to stdout.

## QA

Verified working on
- [Minikube](https://github.com/kubernetes/minikube)
- [KIND (Kubernetes IN Docker)](https://github.com/kubernetes-sigs/kind)
- [Docker For Desktop (Docker for Mac)](https://www.docker.com/products/docker-desktop)
- [microk8s](https://microk8s.io/) - with Microk8s 1.15+, when you run `microk8s.enable rbac`

Won't work with:
- [kubeadm-dind-cluster](https://github.com/kubernetes-sigs/kubeadm-dind-cluster) - Configured to use the insecure API endpoint by default

## Credits

Thanks to:

- [The Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes and RBAC: Restrict User Access to One Namespace by Jeremie Vallee](https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html)
- [Debugging help from Guillaume Rose](https://github.com/docker/for-mac/issues/3694)

## License

Copyright 2019 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)
