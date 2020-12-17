# steadybit Kubernetes Agent Helm Chart

This Helm chart adds the steadybit Agent to all nodes in your Kubernetes cluster via a DaemonSet.

## Quick start

### Add steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Create Kubernetes namespace

```
kubectl create namespace steadybit-agent
```

### Installing the chart

To install the chart with the name `steadybit-agent` and set the values on the command line run:

```bash
$ helm install steadybit-agent --namespace steadybit-agent --set agent.key=STEADYBIT_AGENT_KEY steadybit/steadybit-agent
```

For local development:

```bash
$ helm install steadybit-agent --namespace steadybit-agent ./charts/steadybit-agent --set agent.key=STEADYBIT_AGENT_KEY
```

## Configuration

To see all configurable options with detailed comments, visit the chart's values.yaml, or run these configuration commands:

```
$ helm show values steadybit-agent
```

The following table lists the configurable parameters of the steadybit agent chart and their default values.

|             Parameter              |            Description                                                  |                    Default                                                                                  |
|------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| `agent.key`                        | Your steadybit Agent key                                                | `null` This key is mandatory!                                                                               |
| `agent.registerUrl`                | steadybit Agent register URL                                            | `https://platform.steadybit.io`                                                                             |
| `image.name`                       | The image name to pull                                                  | `docker.steadybit.io/steadybit/agent`                                                                       |
| `image.tag`                        | The image tag to pull                                                   | `latest`                                                                                                    |
| `image.pullPolicy`                 | Image pull policy                                                       | `Always`                                                                                                    |
| `podSecurityPolicy.enable`         | Whether a PodSecurityPolicy should be enabled.                          | `true`                                                                                                      |
| `podSecurityPolicy.name`           | Name of an already existing PodSecurityPolicy                           | `null`                                                                                                      |
| `rbac.create`                      | Whether RBAC resources should be created                                | `true`                                                                                                      |
| `serviceAccount.create`            | Whether a ServiceAccount should be created                              | `true`                                                                                                      |
| `serviceAccount.name`              | Name of the ServiceAccount to use                                       | `steadybit-agent`                                                                                           |

## Uninstallation

```
helm uninstall steadybit-agent -n steadybit-agent
```