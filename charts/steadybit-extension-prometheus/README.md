# Steadybit Prometheus Extension 

This Helm chart adds the Steadybit Prometheus extension to your Kubernetes cluster via a deployment.

## Quick Start

### Add Steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Installing the Chart

To install the chart with the name `steadybit-extension-prometheus` and set the required configuration values.

```bash
$ helm upgrade steadybit-extension-prometheus \
    --install \
    --wait \
    --timeout 5m0s \
    --create-namespace \
    --namespace steadybit-extension \
    --set prometheus.name="dev" \
    --set prometheus.origin="http://prom-prometheus-server.default.svc.cluster.local" \
    steadybit/steadybit-extension-prometheus
```
