{{- /*
extensionlib.daemonset will render a Kubernetes daemonset definition supporting auto-discovery of the extension.

This takes an array of these values:
- the top context
- the port of the extension
- the healthport of the extension
- the supported types of the extension, e.g., (list "ACTION" "DISCOVERY")
- the apparmor security type of the extension, e.g., "unconfined"
- the seccompProfile of the extension, e.g., "Unconfined"
- the needed linux caps of the executable, e.g., (list "NET_RAW" "NET_ADMIN")
- use hostnetwork (true/false)
- define dnsPolicy (ClusterFirstWithHostNet, ClusterFirst, Default, None)
- add container runtime mounts and adds cgroup-root mount (true/false)
*/}}
{{- define "extensionlib.daemonset" -}}
{{- $top := index . 0 -}}
{{- $port := index . 1 -}}
{{- $healthport := index . 2 -}}
{{- $types := index . 3 -}}
{{- $apparmorsecurity := index . 4 -}}
{{- $seccompProfile := index . 5 -}}
{{- $caps := index . 6 -}}
{{- $hostnetwork := index . 7 -}}
{{- $dnsPolicy := index . 8 -}}
{{- $addContainerRuntimeMounts := index . 9 -}}
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
      hostNetwork: {{ $hostnetwork }}
      hostPID: true
      dnsPolicy: {{ $dnsPolicy }}
      containers:
        - image: {{ $top.Values.image.name }}:{{ $top.Values.image.tag }}
          imagePullPolicy: {{ $top.Values.image.pullPolicy }}
          name: {{ include "extensionlib.names.name" $top }}
          env:
            {{- include "extensionlib.deployment.env" (list $top) | nindent 12 }}
            {{- with $top.Values.extraEnv }}
              {{- toYaml . | nindent 12 }}
            {{- end }}
          {{- with $top.Values.extraEnvFrom }}
          envFrom:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: tmp-dir
              mountPath: /tmp
            {{- if $addContainerRuntimeMounts }}
            - name: cgroup-root
              mountPath: /sys/fs/cgroup
                  {{- include "containerRuntime.volumeMounts" $top | nindent 12 }}
            {{- end }}
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
              type: {{ $seccompProfile }}
            capabilities:
              add: {{ toJson $caps }}
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 10000
            runAsGroup: 10000
      volumes:
        - name: tmp-dir
          emptyDir: { }
          {{- if $addContainerRuntimeMounts }}
        - name: cgroup-root
          hostPath:
            path: /sys/fs/cgroup
            type: Directory
            {{- include "containerRuntime.volumes" $top | nindent 8 }}
            {{- end }}
            {{- include "extensionlib.deployment.volumes" (list $top) | nindent 8 }}
          {{- with $top.Values.nodeSelector }}
      nodeSelector:
          {{- toYaml . | nindent 8 }}
          {{- end }}
          {{- with $top.Values.affinity }}
      affinity:
          {{- toYaml . | nindent 8 }}
          {{- end }}
          {{- with $top.Values.tolerations }}
      tolerations:
          {{- toYaml . | nindent 8 }}
          {{- end }}
          {{- with $top.Values.topologySpreadConstraints }}
      topologySpreadConstraints:
          {{- toYaml . | nindent 8 }}
          {{- end }}
{{- end -}}

{{/*
checks the .Values.containerRuntime for valid values
*/}}
{{- define "containerRuntime.valid" -}}
{{- $valid := keys .Values.containerRuntimes | sortAlpha -}}
{{- $runtime := .Values.container.runtime -}}
{{- if has $runtime $valid -}}
{{- $runtime  -}}
{{- else -}}
{{- fail (printf "unknown container runtime: %v (must be one of %s)" $runtime (join ", " $valid)) -}}
{{- end -}}
{{- end -}}


{{- /*
containerRuntime.volumeMounts will render pod volume mounts(without indentation) for the selected container runtime
*/}}
{{- define "containerRuntime.volumeMounts" -}}
{{- $runtime := (include "containerRuntime.valid" . )  -}}
{{- $runtimeValues := get .Values.containerRuntimes $runtime  -}}
- name: "runtime-socket"
  mountPath: "{{ $runtimeValues.socket }}"
- name: "runtime-runc-root"
  mountPath: "{{ $runtimeValues.runcRoot }}"
{{- end -}}

{{- /*
containerRuntime.volumes will render pod volumes (without indentation) for the selected container runtime
*/}}
{{- define "containerRuntime.volumes" -}}
{{- $runtime := (include "containerRuntime.valid" . )  -}}
{{- $runtimeValues := get .Values.containerRuntimes $runtime  -}}
- name: "runtime-socket"
  hostPath:
    path: "{{ $runtimeValues.socket }}"
    type: Socket
- name: "runtime-runc-root"
  hostPath:
    path: "{{ $runtimeValues.runcRoot }}"
    type: Directory
{{- end -}}
