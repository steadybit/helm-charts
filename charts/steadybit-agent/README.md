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
$ helm install steadybit-agent --namespace steadybit-agent --set agent.key=STEADYBIT_AGENT_KEY --set cluster.name=foo steadybit/steadybit-agent
```

For local development:

```bash
$ helm install steadybit-agent --namespace steadybit-agent ./charts/steadybit-agent --set agent.key=STEADYBIT_AGENT_KEY --set cluster.name=foo
```

## Configuration

To see all configurable options with detailed comments, visit the chart's values.yaml, or run these configuration commands:

```
$ helm show values steadybit-agent
```

The following table lists the configurable parameters of the steadybit agent chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinities to influence agent pod assignment. |
| agent.additionalVolumes | list | `[]` | Additional volumes to which the agent container will be mounted. |
| agent.containerRuntime | string | `"docker"` | The container runtime to be used. Valid values:    docker     = uses the docker runtime.                 Will mount [/var/run/docker.sock] |
| agent.env | object | `{}` | Additional environment variables for the steadybit agent |
| agent.extraLabels | object | `{}` | Additional labels |
| agent.key | string | `nil` | The secret token which your agent uses to authenticate to steadybit's servers. Get it from  Get it from https://platform.steadybit.io/settings/agents/setup. |
| agent.registerUrl | string | `"https://platform.steadybit.io"` | The URL of the steadybit server your agents will connect to. |
| cluster.name | string | `nil` | Represents the name that will be assigned to this Kubernetes cluster in steadybit. |
| image.name | string | `"docker.steadybit.io/steadybit/agent"` | The container image  to use of the steadybit agent. |
| image.pullPolicy | string | `"Always"` | Specifies when to pull the image container. |
| image.tag | string | `"latest"` | tag name of the agent container image to use. |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Additional annotations to be added to the agent pods. |
| podSecurityPolicy.enable | bool | `false` | Specifies whether a PodSecurityPolicy should be authorized for the steadybit Agent pods. Requires `rbac.create` to be `true` as well. |
| podSecurityPolicy.name | string | `nil` | The name of an existing PodSecurityPolicy you would like to authorize for the steadybit Agent pods. If not set and `enable` is true, a PodSecurityPolicy will be created with a name generated using the fullname template. |
| rbac.create | bool | `true` | Specifies whether RBAC resources should be created. |
| rbac.readonly | bool | `true` | Specifies if Kubernetes API access should only be read only. |
| serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created. |
| serviceAccount.name | string | `"steadybit-agent"` | The name of the ServiceAccount to use. If not set and `create` is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations to influence agent pod assignment. |
| updateStrategy.rollingUpdate.maxUnavailable | int | `1` | |
| updateStrategy.type | string | `"RollingUpdate"` | Which type of `updateStrategy` should be used. |

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

### Configuring Additional Environment Variables

You may want to do some [advanced configuration](https://docs.steadybit.io/installation-agent/4-advanced-configuration) of the agent, e.g. for debugging purposes or adding a Maven proxy.

```yaml
agent:
  env:
    STEADYBIT_LOG_LEVEL: DEBUG
    STEADYBIT_REPOSITORY_PROXY_HOST: localhost
    STEADYBIT_REPOSITORY_PROXY_PORT: 8080
    STEADYBIT_REPOSITORY_PROXY_USERNAME: foo
    STEADYBIT_REPOSITORY_PROXY_PASSWORD: bar
```

## Uninstallation

```
helm uninstall steadybit-agent -n steadybit-agent
```