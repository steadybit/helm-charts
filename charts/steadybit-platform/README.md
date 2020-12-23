# steadybit Kubernetes Platform Helm Chart

This Helm chart installs the steadybit Platform into your Kubernetes cluster via a Deployment.

## Quick start

### Add steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Create Kubernetes namespace

```
kubectl create namespace steadybit-platform
```

### Installing the chart

To install the chart with the name `steadybit-platform` and set the values on the command line run:

```bash
$ helm install steadybit-platform --namespace steadybit-platform --set agent.key=STEADYBIT_AGENT_KEY steadybit/steadybit-platform
```

For local development:

```bash
$ helm install steadybit-platform --namespace steadybit-platform ./charts/steadybit-platform --set agent.key=STEADYBIT_AGENT_KEY
```

## Configuration

To see all configurable options with detailed comments, visit the chart's values.yaml, or run these configuration commands:

```
$ helm show values steadybit-platform
```

The following table lists the configurable parameters of the steadybit platform chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agent.key | string | `nil` | The secret token which your agent uses to authenticate to steadybit's servers.  Get it from https://platform.steadybit.io/settings/agents/setup. |
| image.name | string | `"docker.steadybit.io/steadybit/platform"` | The container image  to use of the steadybit platform. |
| image.pullPolicy | string | `"Always"` | Specifies when to pull the image container. |
| image.tag | string | `"latest"` | Tag name of the platform container image to use. |
| ingress | object | `{"annotations":null,"enabled":true,"hosts":[]}` | Ingress configuration properties |
| platform.database | object | `{"enabled":true,"image":{"name":"postgres","pullPolicy":"Always","tag":11.5},"name":"steadybitdb","password":"postgres","port":5432,"url":"jdbc:postgresql://postgres.steadybit-platform:5432/steadybitdb","user":"postgres"}` | Specific configuration for the database. |
| platform.env | object | `{"STEADYBIT_AUTH_PROVIDER":"static","STEADYBIT_AUTH_STATIC_0_PASSWORD":"{noop}admin","STEADYBIT_AUTH_STATIC_0_USERNAME":"admin"}` | Use this to set additional environment variables See https://docs.steadybit.io/installation-platform/3-advanced-configuration. |
| platform.tenant.key | string | `"onprem"` | Name for the tenant assigned to you. |
| platform.tenant.name | string | `"onprem"` | Key for the tenant assigned to you. |
| platform.uiPort | int | `80` | Web-UI port for the user interface. |
| platform.websocketPort | int | `7878` | Websocket port for communication between platform and agents. |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created. |

### YAML file 

If you have to modify more than 1 property (e.g. agent key), it makes maybe sense to consider to configure the Helm chart with a YAML file and pass it to the install/upgrade command.

1. **Copy the default [`steadybit-values.yaml`](values.yaml) value file.**
2. Set the `agent.key` parameter with your [steadybit agent key](https://platform.steadybit.io/settings/agents/setup).
3. Modify more parameter for your own needs, e.g. database configuration.
4. Upgrade the Helm chart with the new `steadybit-values.yaml` file:

```bash
$ helm install -f steadybit-values.yaml steadybit-platform --namespace steadybit-platform steadybit/steadybit-platform
```

### Configuring Ingress in AWS EKS

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
  hosts: []
```

## Uninstallation

```
helm uninstall steadybit-platform -n steadybit-platform
```