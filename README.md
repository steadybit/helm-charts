# Steadybit Kubernetes Helm Charts

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/steadybit)](https://artifacthub.io/packages/search?repo=steadybit)

This repository hosts the source of the Steadybit Kubernetes helm charts.

Currently supported:

- [Steadybit Agent](charts/steadybit-agent/README.md)
- [Steadybit Platform](charts/steadybit-platform/README.md)

## How to use the Steadybit Helm repository

You need to add this repository to your Helm repositories:

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```