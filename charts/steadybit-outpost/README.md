# steadybit Kubernetes Outpost Helm Chart

This Helm chart adds the steadybit outpost to your Kubernetes cluster.

## Quick start

### Add steadybit Helm repository

```
helm repo add steadybit https://steadybit.github.io/helm-charts
helm repo update
```

### Installing the chart

To install the chart with the name `steadybit-outpost` and set the values on the command line run:

```bash
$ helm install steadybit-outpost --namespace steadybit-outpost --create-namespace --set outpost.key=STEADYBIT_AGENT_KEY --set global.clusterName=CLUSTER_NAME steadybit/steadybit-outpost
```

## Configuration

To see all configurable options with detailed comments, visit the chart's values.yaml, or run these configuration commands:

```
$ helm show values steadybit-outpost
```

The following table lists the configurable parameters of the steadybit outpost chart and their default values.

| Key                                         | Type    | Default                            | Description                                                                                                                                                    |
|---------------------------------------------|---------|------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|
| affinity                                    | object  | `{}`                               | Affinities to influence outpost pod assignment.                                                                                                                |
| global.clusterName                          | string  | `nil`                              | Represents the name that will be assigned to this Kubernetes cluster in steadybit.                                                                             |
| outpost.extraVolumes                        | list    | `[]`                               | Additional volumes to which the outpost container will be mounted.                                                                                             |
| outpost.extraVolumeMounts                   | list    | `[]`                               | Additional volumeMounts to which the outpost container will be mounted.                                                                                        |
| outpost.env                                 | array   | `[]`                               | Additional environment variables for the steadybit outpost                                                                                                     |
| outpost.extraLabels                         | object  | `{}`                               | Additional labels                                                                                                                                              |
| outpost.key                                 | string  | `nil`                              | The secret token which your outpost uses to authenticate to steadybit's servers. Get it from  Get it from https://platform.steadybit.io/settings/agents/setup. |
| outpost.registerUrl                         | string  | `"https://platform.steadybit.com"` | The URL of the steadybit server the outpost will connect to.                                                                                                   |
| outpost.proxy.host                          | string  | `nil`                              | Hostname or address of your proxy                                                                                                                              |
| outpost.proxy.port                          | int     | `80`                               | Port of your proxy                                                                                                                                             |
| outpost.proxy.protocol                      | string  | `"HTTP"`                           | proxy protocol                                                                                                                                                 |
| outpost.proxy.user                          | string  | `nil`                              | username of the proxy auth (if needed)                                                                                                                         |
| outpost.proxy.password                      | string  | `nil`                              | password of the proxy auth (if needed)                                                                                                                         |
| image.name                                  | string  | `"steadybit/outpost"`              | The container image  to use of the steadybit outpost.                                                                                                          |
| image.pullPolicy                            | string  | `"Always"`                         | Specifies when to pull the image container.                                                                                                                    |
| image.tag                                   | string  | `"latest"`                         | tag name of the outpost container image to use.                                                                                                                |
| resources.limits.memory                     | string  | `"500Mi"`                          | memory resource limit for the outpost container                                                                                                                |
| resources.limits.cpu                        | string  | `"1000m"`                          | cpu resource limit for the outpost container                                                                                                                   |
| resources.requests.memory                   | string  | `"250Mi"`                          | memory resource limit for the outpost container                                                                                                                |
| resources.requests.cpu                      | string  | `"125m"`                           | cpu resource limit for the outpost container                                                                                                                   |
| nodeSelector                                | object  | `{}`                               | Node labels for pod assignment                                                                                                                                 |
| podAnnotations                              | object  | `{}`                               | Additional annotations to be added to the outpost pods.                                                                                                        |
| rbac.create                                 | bool    | `true`                             | Specifies whether RBAC resources should be created.                                                                                                            |
| rbac.readonly                               | bool    | `true`                             | Specifies if Kubernetes API access should only be read only.                                                                                                   |
| serviceAccount.create                       | bool    | `true`                             | Specifies whether a ServiceAccount should be created.                                                                                                          |
| serviceAccount.name                         | string  | `"steadybit-outpost"`              | The name of the ServiceAccount to use. If not set and `create` is true, a name is generated using the fullname template.                                       |
| serviceAccount.eksRoleArn                   | string  | `nil`                              | The arn of the IAM role - [see aws docs](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)                                   |
| tolerations                                 | list    | `[]`                               | Tolerations to influence outpost pod assignment.                                                                                                               |
| updateStrategy.rollingUpdate.maxUnavailable | int     | `1`                                |                                                                                                                                                                |
| updateStrategy.type                         | string  | `"RollingUpdate"`                  | Which type of `updateStrategy` should be used.                                                                                                                 |
| extension-aws.enabled                       | boolean | `false`                            | Enables the AWS extension. Further config may be required.                                                                                                     |
| extension-container.enabled                 | boolean | `true`                             | Enables the container extension. Further config may be required.                                                                                               |
| extension-container.container.runtime       | string  | `containerd`                       | The container runtime.                                                                                                                                         |
| extension-datadog.enabled                   | boolean | `false`                            | Enables the datadog extension. Further config may be required.                                                                                                 |
| extension-host.enabled                      | boolean | `true`                             | Enables the host extension. Further config may be required.                                                                                                    |
| extension-http.enabled                      | boolean | `true`                             | Enables the HTTP extension. Further config may be required.                                                                                                    |
| extension-istio.enabled                     | boolean | `false`                            | Enables the Istio extension. Further config may be required.                                                                                                   |
| extension-gatling.enabled                   | boolean | `false`                            | Enables the Gatling extension. Further config may be required.                                                                                                 |
| extension-jmeter.enabled                    | boolean | `false`                            | Enables the JMeter extension. Further config may be required.                                                                                                  |
| extension-k6.enabled                        | boolean | `false`                            | Enables the K6 extension. Further config may be required.                                                                                                      |
| extension-kong.enabled                      | boolean | `false`                            | Enables the kong extension. Further config may be required.                                                                                                    |
| extension-kubernetes.enabled                | boolean | `true`                             | Enables the kubernetes extension. Further config may be required.                                                                                              |
| extension-postman.enabled                   | boolean | `false`                            | Enables the postman extension. Further config may be required.                                                                                                 |
| extension-prometheus.enabled                | boolean | `false`                            | Enables the prometheus extension. Further config may be required.                                                                                              |

### YAML file

If you have to modify more than 1 property (e.g. outpost key), it makes maybe sense to consider to configure the Helm chart with a YAML file and pass it to the
install/upgrade command.

1. **Copy the default [`steadybit-values.yaml`](values.yaml) value file.**
2. Set the `outpost.key` parameter with your [steadybit agent key](https://platform.steadybit.io/settings/agents/setup).
3. Modify more parameter for your own needs, e.g. adding [additional volume mounts](#configuring-additional-volumes).
4. Upgrade the Helm chart with the new `steadybit-values.yaml` file:

```bash
$ helm install -f steadybit-values.yaml steadybit-outpost --namespace steadybit-outpost steadybit/steadybit-outpost
```

### Importing your own certificates

You may want to import your own certificates. You just need the to provide a volume named `extra-certs`.

This example uses a config map to store the `*.crt`-files in a configmap:

```
kubectl create configmap -n steadybit-outpost self-signed-ca --from-file=./self-signed-ca.crt
```

```yaml
outpost:
  extraVolumes:
    - name: extra-certs
      configMap:
        name: self-signed-ca #uses a certificates from the secret "self-signed-ca"
```

-OR-

```yaml
outpost:
  extraVolumes:
    - name: extra-certs
      hostPath: /ssca/ca # path with additional certificates
```

### Configuring Additional Volumes

You may want to have additional volumes to be mounted to the outpost container, e.g. for SSL certificates.

```yaml
outpost:
  extraVolumeMounts:
    - name: tmp # Volume's name.
      mountPath: /tmp # Path within the container at which the volume should be mounted.
  extraVolumes:
    - name: tmp # Volume's name.
      hostPath:
        path: /tmp # Pre-existing file or directory on the host machine
```

### Configuring Additional Environment Variables

You may want to do some [advanced configuration](https://docs.steadybit.io/installation-agent/4-advanced-configuration) of the outpost, e.g. for debugging
purposes or adding a Maven proxy.

```yaml
outpost:
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
helm uninstall steadybit-outpost -n steadybit-outpost
```
