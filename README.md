# steadybit Kubernetes Helm Charts

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steadybit)](https://artifacthub.io/packages/search?repo=steadybit)

This repository hosts the source of the Steadybit Kubernetes helm charts.

Currently supported:

- [steadybit Agent](charts/steadybit-agent/README.md)
- [steadybit Platform](charts/steadybit-platform/README.md)
- [steadybit AWS extension](charts/steadybit-extension-aws/README.md)
- [steadybit Kong extension](charts/steadybit-extension-kong/README.md)
- [steadybit Postman extension](charts/steadybit-extension-postman/README.md)
- [steadybit Prometheus extension](charts/steadybit-extension-prometheus/README.md)

## How to use the steadybit Helm repository

You need to add this repository to your Helm repositories: 

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```