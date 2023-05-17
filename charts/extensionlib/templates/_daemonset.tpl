{{- /*
extensionlib.daemonset will render a Kubernetes daemonset definition supporting auto-discovery of the extension.

This takes an array of these values:
- the top context
- the port of the extension
- the healthport of the extension
- the supported types of the extension, e.g., (list "ACTION" "DISCOVERY")
- the apparmor security type of the extension, e.g., "unconfined"
- the needed linux caps of the executable, e.g., (list "NET_RAW" "NET_ADMIN")
*/}}
{{- define "extensionlib.daemonset" -}}
{{- $top := index . 0 -}}
{{- $port := index . 1 -}}
{{- $healthport := index . 2 -}}
{{- $types := index . 3 -}}
{{- $apparmorsecurity := index . 4 -}}
{{- $caps := index . 5 -}}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "extensionlib.names.fullname" $top }}
  namespace: {{ $top.Release.Namespace }}
  labels:
  {{- range $key, $value := $top.Values.extraLabels }}
    {{ $key }}: {{ $value }}
  {{- end }}
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "extensionlib.names.name" $top }}
      app: {{ include "extensionlib.names.name" $top }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "extensionlib.names.name" $top }}
        app: {{ include "extensionlib.names.name" $top }}
        steadybit.com/extension: "true"
  annotations:
    "container.apparmor.security.beta.kubernetes.io/{{ include "extensionlib.names.name" $top }}": {{ $apparmorsecurity }}
    "steadybit.com/extension-auto-discovery": >
      {
        "extensions": [
          {
            "port": {{ $port }},
            "types": {{ toJson $types }},
            "tls": {
              {{- if $top.Values.tls.server.certificate.fromSecret }}
              "server": {
                "extraCertsFile": "{{ $top.Values.tls.server.certificate.fromSecret }}/tls.crt"
              {{ if $top.Values.tls.client.certificates.fromSecrets -}}
              },
              {{- else -}}
              }
              {{- end -}}
              {{- end }}
              {{ if $top.Values.tls.client.certificates.fromSecrets -}}
              "client": {
                "certChainFile": "{{ first $top.Values.tls.client.certificates.fromSecrets }}/tls.crt",
                "certKeyFile": "{{ first $top.Values.tls.client.certificates.fromSecrets }}/tls.key"
              }
              {{- end }}
            }
          }
        ]
      }
    spec:
      hostNetwork: true
      hostPID: true
      dnsPolicy: ClusterFirstWithHostNet
      containers:
        - image: {{ $top.Values.image.name }}:{{ $top.Values.image.tag }}
          imagePullPolicy: {{ $top.Values.image.pullPolicy }}
          name: {{ include "extensionlib.names.name" $top }}
          env:
            {{- include "extensionlib.deployment.env" (list $top) | nindent 12 }}
            {{- with $top.Values.extraEnv }}
              {{- toYaml $top | nindent 12 }}
            {{- end }}
          {{- with $top.Values.extraEnvFrom }}
          envFrom:
            {{- toYaml $top | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: tmp-dir
              mountPath: /tmp
                  {{- include "extensionlib.deployment.volumeMounts" (list $top) | nindent 12 }}
          livenessProbe:
            httpGet:
              path: /health/liveness
              port: {{ $healthport }}
          readinessProbe:
            httpGet:
              path: /health/readiness
              port: {{ $healthport }}
          securityContext:
            seccompProfile:
              type: {{ $apparmorsecurity }}
            capabilities:
              add: {{ toJson $caps }}
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 10000
            runAsGroup: 10000
      volumes:
        - name: tmp-dir
          emptyDir: { }
            {{- include "extensionlib.deployment.volumes" (list $top) | nindent 8 }}
          {{- with $top.Values.nodeSelector }}
      nodeSelector:
          {{- toYaml $top | nindent 8 }}
          {{- end }}
          {{- with $top.Values.affinity }}
      affinity:
          {{- toYaml $top | nindent 8 }}
          {{- end }}
          {{- with $top.Values.tolerations }}
      tolerations:
          {{- toYaml $top | nindent 8 }}
          {{- end }}
          {{- with $top.Values.topologySpreadConstraints }}
      topologySpreadConstraints:
          {{- toYaml $top | nindent 8 }}
          {{- end }}
{{- end -}}