# steadybit Kubernetes Helm Charts

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steadybit)](https://artifacthub.io/packages/search?repo=steadybit)

This repository hosts the source of the Steadybit Kubernetes helm charts.

Currently supported:

- [steadybit Outpost](charts/steadybit-outpost/README.md)
- [steadybit Platform](charts/steadybit-platform/README.md)

## How to use the steadybit Helm repository

You need to add this repository to your Helm repositories: 

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```