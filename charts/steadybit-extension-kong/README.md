# Steadybit Kong Extension 

This Helm chart adds the Steadybit Kong extension to your Kubernetes cluster via a deployment.

## Quick Start

### Add Steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Installing the Chart

To install the chart with the name `steadybit-extension-kong` and set the required configuration values.

```bash
$ helm upgrade steadybit-extension-kong \
    --install \
    --wait \
    --timeout 5m0s \
    --create-namespace \
    --namespace steadybit-extension \
    --set kong.name="dev" \
    --set kong.origin="http://kong.example.com:8001" \
    steadybit/steadybit-extension-kong
```
