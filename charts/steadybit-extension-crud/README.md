# Steadybit CRUD Extension 

**Note: This extension is only useful for extension development and demonstrative purposes.**

This Helm chart adds the Steadybit CRUD extension to your Kubernetes cluster via a deployment.

## Quick Start

### Add Steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Installing the Chart

To install the chart with the name `steadybit-extension-crud` and set the required configuration values.

```bash
$ helm upgrade steadybit-extension-crud \
    --install \
    --wait \
    --timeout 5m0s \
    --create-namespace \
    --namespace steadybit-extension \
    --set crud.instanceName='Dog Shelter' \
    --set crud.targetType=dog \
    --set crud.targetTypeLabel=Dog \
    steadybit/steadybit-extension-crud
```

### Common Configuration

The following represents a typical configuration to test multiple configured instances of the same (simulated) extension.

```bash
$ helm upgrade dog-shelter \
    --install \
    --wait \
    --timeout 5m0s \
    --create-namespace \
    --namespace steadybit-extension \
    --set crud.instanceName='Dog Shelter' \
    --set crud.targetType=crud.dog \
    --set crud.targetTypeLabel=Dog \
    --set deployment.name=steadybit-extension-crud-dog-shelter \
    --set service.name=steadybit-extension-crud-dog-shelter \
    steadybit/steadybit-extension-crud

$ helm upgrade animal-shelter \
    --install \
    --wait \
    --timeout 5m0s \
    --create-namespace \
    --namespace steadybit-extension \
    --set crud.instanceName='Animal Shelter' \
    --set crud.targetType=crud.dog \
    --set crud.targetTypeLabel=Dog \
    --set deployment.name=steadybit-extension-crud-animal-shelter \
    --set service.name=steadybit-extension-crud-animal-shelter \
    steadybit/steadybit-extension-crud
```