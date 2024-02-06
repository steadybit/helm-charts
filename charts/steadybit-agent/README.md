# steadybit Kubernetes Agent Helm Chart

This Helm chart adds the steadybit agent to your Kubernetes cluster.

## Quick start

### Add steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Installing the chart

To install the chart with the name `steadybit-agent` and set the values on the command line run:

```bash
$ helm install steadybit-agent --namespace steadybit-agent --create-namespace --set agent.key=STEADYBIT_AGENT_KEY --set global.clusterName=CLUSTER_NAME steadybit/steadybit-agent
```

## Configuration Options

To see all configurable options with detailed comments, visit the chart's [values.yaml](values.yaml), or run these configuration commands:

```
$ helm show values steadybit-agent
```

### YAML file

If you have to modify more than 1 property (e.g. agent key), it makes maybe sense to consider to configure the Helm chart with a YAML file and pass it to the
install/upgrade command.

1. **Copy the default [`steadybit-values.yaml`](values.yaml) value file.**
2. Set the `agent.key` parameter with your [steadybit agent key](https://platform.steadybit.io/settings/agents/setup).
3. Modify more parameter for your own needs, e.g. adding [additional volume mounts](#configuring-additional-volumes).
4. Upgrade the Helm chart with the new `steadybit-values.yaml` file:

```bash
$ helm install -f steadybit-values.yaml steadybit-agent --namespace steadybit-agent steadybit/steadybit-agent
```

### Importing your own certificates

You may want to import your own certificates. Mount a volume with the certificates and reference it in `agent.extraCertificates.fromVolume`.

This example uses a config map to store the `*.crt`-files in a configmap:

```shell
kubectl create configmap -n steadybit-agent self-signed-ca --from-file=./self-signed-ca.crt
```

```yaml
agent:
  extraCertificates:
    fromVolume: extra-certs
  extraVolumes:
    - name: extra-certs
      configMap:
        name: self-signed-ca
```

-OR-

You can also reference a path in the container use `agent.extraCertificates.containerPath`

```yaml
agent:
  extraCertificates:
    container-path: /path/to/certificates
```

### Configuring Additional Volumes

You may want to have additional volumes to be mounted to the agent container, e.g. for SSL certificates.

```yaml
agent:
  extraVolumeMounts:
    - name: tmp # Volume's name.
      mountPath: /tmp # Path within the container at which the volume should be mounted.
  extraVolumes:
    - name: tmp # Volume's name.
      hostPath:
        path: /tmp # Pre-existing file or directory on the host machine
```

### Configuring Additional Environment Variables

You may want to do some [advanced configuration](https://docs.steadybit.com/install-and-configure/install-agent/advanced-configuration) of the agent, e.g. for debugging
purposes or adding a Maven proxy.

```yaml
agent:
  env:
    - name: STEADYBIT_LOG_LEVEL
      value: "DEBUG"
    - name: STEADYBIT_REPOSITORY_PROXY_HOST
      value: "localhost"
    - name: STEADYBIT_REPOSITORY_PROXY_PORT
      value: "8080"
    - name: STEADYBIT_REPOSITORY_PROXY_USERNAME
      value: "foo"
    - name: STEADYBIT_REPOSITORY_PROXY_PASSWORD
      value: "bar"
```

## Uninstallation

```
helm uninstall steadybit-agent -n steadybit-agent
```
