# Steadybit AWS Extension 

This Helm chart adds the Steadybit AWS extension to your Kubernetes cluster via a deployment.

## Quick Start

### Add Steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Installing the Chart

To install the chart with the name `steadybit-extension-aws` and set the required configuration values.
To learn more about the required EKS role ARN, please refer to the [extension-aws README](https://github.com/steadybit/extension-aws).

```bash
$ helm upgrade steadybit-extension-aws \
    --install \
    --wait \
    --timeout 5m0s \
    --create-namespace \
    --namespace steadybit-extension \
    --set serviceAccount.eksRoleArn="TODO EKS ROLE ARN" \
    steadybit/steadybit-extension-aws
```
