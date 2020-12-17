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
| `agent.key`                        | Your steadybit Agent key                                                | `null` This key is mandatory!  Get it from https://platform.steadybit.io/settings/agents/setup              |
| `agent.registerUrl`                | steadybit Agent register URL                                            | `https://platform.steadybit.io`                                                                             |
| `agent.additionalVolumes`          | See [Configuring Additional Volumes](#configuring-additional-volumes)   | `[]`                                                                                                        |
| `image.name`                       | The image name to pull                                                  | `docker.steadybit.io/steadybit/agent`                                                                       |
| `image.tag`                        | The image tag to pull                                                   | `latest`                                                                                                    |
| `image.pullPolicy`                 | Image pull policy                                                       | `Always`                                                                                                    |
| `podSecurityPolicy.enable`         | Whether a PodSecurityPolicy should be enabled.                          | `true`                                                                                                      |
| `podSecurityPolicy.name`           | Name of an already existing PodSecurityPolicy                           | `null`                                                                                                      |
| `rbac.create`                      | Whether RBAC resources should be created                                | `true`                                                                                                      |
| `serviceAccount.create`            | Whether a ServiceAccount should be created                              | `true`                                                                                                      |
| `serviceAccount.name`              | Name of the ServiceAccount to use                                       | `steadybit-agent`                                                                                           |

### YAML file 

If you have to modify more than 1 property (e.g. agent key), it makes maybe sense to consider to configure the Helm chart with a YAML file and pass it to the install/upgrade command.

1. **Copy the default [`steadybit-values.yaml`](values.yaml) value file.**
2. Set the `agent.key` parameter with your [steadybit agent key](https://platform.steadybit.io/settings/agents/setup).
3. Modify more parameter for your own needs, e.g. adding [additional volume mounts](#configuring-additional-volumes).
4. Upgrade the Helm chart with the new `steadybit-values.yaml` file:

```bash
$ helm install -f steadybit-values.yaml steadybit-agent --namespace steadybit-agent steadybit/steadybit-agent
```

### Configuring Additional Volumes

You may want to have additional volumes to be mounted to the agent container, e.g. for SSL certificates.

```yaml
agent:
  additionalVolumes:
    - name: tmp # Volume's name.
      mountPath: /tmp # Path within the container at which the volume should be mounted.
      hostPath: /tmp # Pre-existing file or directory on the host machine
```

## Uninstallation

```
helm uninstall steadybit-agent -n steadybit-agent
```