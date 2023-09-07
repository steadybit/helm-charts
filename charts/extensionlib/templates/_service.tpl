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
    {{- include "extensionlib.annotation" . | nindent 4 }}
spec:
  selector:
    {{- include "extensionlib.selectorLabels" $top | nindent 4 }}
  ports:
    - protocol: TCP
      port: {{ $port }}
      targetPort: {{ $port }}
{{- end -}}