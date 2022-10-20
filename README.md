# Steadybit Kubernetes Helm Charts

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steadybit)](https://artifacthub.io/packages/search?repo=steadybit)

This repository hosts the source of the Steadybit Kubernetes helm charts.

Currently supported:

- [Steadybit Agent](charts/steadybit-agent/README.md)
- [Steadybit Platform](charts/steadybit-platform/README.md)
- [Steadybit AWS extension](charts/steadybit-extension-aws/README.md)
- [Steadybit Kong extension](charts/steadybit-extension-kong/README.md)
- [Steadybit Kubernetes extension](charts/steadybit-extension-kubernetes/README.md)
- [Steadybit Litmus extension](charts/steadybit-extension-litmus/README.md)
- [Steadybit Postman extension](charts/steadybit-extension-postman/README.md)
- [Steadybit Prometheus extension](charts/steadybit-extension-prometheus/README.md)

## How to use the Steadybit Helm repository

You need to add this repository to your Helm repositories: 

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```