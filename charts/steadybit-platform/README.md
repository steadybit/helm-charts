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

| Key                          | Type   | Default                                                                                                                                                                                                                         | Description                                                                                                                                                                   |
|------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| affinity                     | object | `{}`                                                                                                                                                                                                                            | Affinities to influence platform pod assignment.                                                                                                                              |
| agent.key                    | string | `nil`                                                                                                                                                                                                                           | The secret token which your agent uses to authenticate to steadybit's servers. Get it from https://platform.steadybit.io/settings/agents/setup.                               |
| image.name                   | string | `"docker.steadybit.io/steadybit/platform"`                                                                                                                                                                                      | The container image  to use of the steadybit platform.                                                                                                                        |
| image.pullPolicy             | string | `"Always"`                                                                                                                                                                                                                      | Specifies when to pull the image container.                                                                                                                                   |
| image.tag                    | string | `"latest"`                                                                                                                                                                                                                      | Tag name of the platform container image to use.                                                                                                                              |
| ingress                      | object | `{"annotations":null,"enabled":true,"hosts":[]}`                                                                                                                                                                                | Ingress configuration properties                                                                                                                                              |
| nodeSelector                 | object | `{}`                                                                                                                                                                                                                            | Node labels for pod assignment                                                                                                                                                |
| platform.database            | object | `{"enabled":true,"image":{"name":"postgres","pullPolicy":"Always","tag":11.5},"name":"steadybitdb","password":"postgres","port":5432,"url":"jdbc:postgresql://postgres.steadybit-platform:5432/steadybitdb","user":"postgres"}` | Specific configuration for the database.                                                                                                                                      |
| platform.env                 | array  | `[{"name:", "STEADYBIT_AUTH_PROVIDER", "value": "static"},{"name":"STEADYBIT_AUTH_STATIC_0_PASSWORD", "value": "{noop}admin"},{"name":"STEADYBIT_AUTH_STATIC_0_USERNAME", "value":"admin"}]`                                    | Use this to set additional environment variables See https://docs.steadybit.io/installation-platform/3-advanced-configuration.                                                |
| platform.extraLabels         | object | `{}`                                                                                                                                                                                                                            | Additional labels                                                                                                                                                             |
| platform.tenant.key          | string | `"onprem"`                                                                                                                                                                                                                      | Name for the tenant assigned to you.                                                                                                                                          |
| platform.tenant.name         | string | `"onprem"`                                                                                                                                                                                                                      | Key for the tenant assigned to you.                                                                                                                                           |
| platform.uiPort              | int    | `80`                                                                                                                                                                                                                            | (internal) Web-UI port for the user interface.                                                                                                                                |
| platform.websocketPort       | int    | `7878`                                                                                                                                                                                                                          | (internal) Websocket port for communication between platform and agents.                                                                                                      |
| platform.publicWebsocketPort | int    | `80`                                                                                                                                                                                                                            | The public port used for experiments - Use this if the agent access the websocket via ingress or a reverse proxy, that serves websocket and http traffic using the same port  |
| platform.service.type        | string | `NodePort`                                                                                                                                                                                                                      | Service Type to use for the platform                                                                                                                                          |
| podAnnotations               | object | `{}`                                                                                                                                                                                                                            | Additional annotations to be added to the platform pod.                                                                                                                       |
| serviceAccount.create        | bool   | `true`                                                                                                                                                                                                                          | Specifies whether a ServiceAccount should be created.                                                                                                                         |
| tolerations                  | list   | `[]`                                                                                                                                                                                                                            | Tolerations to influence platform pod assignment.                                                                                                                             |
### YAML file 

If you have to modify more than 1 property (e.g. agent key), we recommend to consider to configure the Helm chart with a YAML file and pass it to the install/upgrade command.

1. **Copy the default [`values.yaml`](values.yaml) value file.**
2. Set the `agent.key` parameter with your [steadybit agent key](https://platform.steadybit.io/settings/agents/setup).
3. Modify more parameter for your own needs, e.g. database configuration.
4. Upgrade the Helm chart with the new `steadybit-values-platform.yaml` file:

```bash
$ helm install -f steadybit-values-platform.yaml steadybit-platform --namespace steadybit-platform steadybit/steadybit-platform
```

### Configuring Ingress in AWS EKS

```yaml
agent:
  key: <replace-with-agent-key>

platform:
  publicWebsocketPort: 80

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

## Splitting ingress/egress ports

By default, the Steadybit platform exposes the ingress (agent communication into the platform) and egress (UI/API data access) endpoints under the same port. For compliance with security policies you may also choose to split the ingress and egress endpoints by port. This helm chart supports this split. 

To enable port splitting, you need to set the following values:

 - `platform.portSplit.portSplit.enabled=true` to start a sidecar container that implements port splitting.
 - `platform.ingressOrigin=https://ingress.steadybit.example.com` to add additional configuration to the Steadybit platform so that it can generate the correct agent configuration values.
 - `ingress.enabled=false` to disable the automatic creation of Kubernetes ingress configurations.

This will, among others, result in a Kubernetes service exposing these ingress and egress ports. It is your responsibility to expose these ports to your internal systems/users as you see fit. For example, you may choose
to define two Kubernetes ingress configurations for ingress and egress as shown below:

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: platform-ingress
spec:
  rules:
    - host: ingress.steadybit.example.com
      http:
        paths:
          - pathType: Prefix
            path: /
            backend:
              service:
                name: steadybit-platform
                port:
                  number: 8082
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: platform-egress
spec:
  rules:
    - host: egress.steadybit.example.com
      http:
        paths:
          - pathType: Prefix
            path: /
            backend:
              service:
                name: steadybit-platform
                port:
                  number: 8081
```