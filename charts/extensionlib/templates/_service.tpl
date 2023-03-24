{{- /*
extensionlib.service will render a Kubernetes service definition supporting auto-discovery of the extension.

This takes an array of these values:
- the top context
- the port of the extension
- the supported types of the extension, e.g., (list "ACTION" "DISCOVERY")
*/}}
{{- define "extensionlib.service" -}}
{{- $top := index . 0 -}}
{{- $port := index . 1 -}}
{{- $types := index . 2 -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "extensionlib.names.fullname" $top }}
  namespace: {{ $top.Release.Namespace }}
  labels:
  {{- range $key, $value := $top.Values.extraLabels }}
    {{ $key }}: {{ $value }}
  {{- end }}
  annotations:
    "steadybit.com/extension-auto-discovery": >
      {
        "extensions": [
          {
            "port": {{ $port }},
            "types": {{ toJson $types }},
            "tls": {
              {{- if $top.Values.tls.server.certificate.fromSecret }}
              "server": {
                "extraCertsFile": "/opt/steadybit/agent/etc/extension-mtls/{{ $top.Values.tls.server.certificate.fromSecret }}/tls.crt"
              {{ if $top.Values.tls.client.certificates.fromSecrets -}}
              },
              {{- else -}}
              }
              {{- end -}}
              {{- end }}
              {{ if $top.Values.tls.client.certificates.fromSecrets -}}
              "client": {
                "certChainFile": "/opt/steadybit/agent/etc/extension-mtls/{{ first $top.Values.tls.client.certificates.fromSecrets }}/tls.crt",
                "certKeyFile": "/opt/steadybit/agent/etc/extension-mtls/{{ first $top.Values.tls.client.certificates.fromSecrets }}/tls.key"
              }
              {{- end }}
            }
          }
        ]
      }
spec:
  selector:
    app.kubernetes.io/name: {{ include "extensionlib.names.name" $top }}
  ports:
    - protocol: TCP
      port: {{ $port }}
      targetPort: {{ $port }}
{{- end -}}