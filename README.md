# Kubernetes RBAC Testing

Shell scripts for help automating RBAC setup on test Kubernetes clusters

The primary purpose is to create:
- a service account
- a namespace
- RBAC rules that restrict the service account to only read/write to that namespace
- a kubeconfig for the service account

Verified working on
- Minikube
- KIND
- Docker For Desktop (Docker for Mac)

## Credits

Thanks to:

- [The Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes and RBAC: Restrict User Access to One Namespace by Jeremie Vallee](https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html)
- [Debugging help from Guillaume Rose](https://github.com/docker/for-mac/issues/3694)

## License

Copyright 2018 Windmill Engineering

Licensed under [the Apache License, Version 2.0](LICENSE)