{{/*
generates environment variables for mtls configuration
*/}}
{{- define "mtlsEnv" -}}
{{ if .tls.clientCertificate.fromSecret -}}
- name: {{ .env_prefix }}_CLIENT_CERT_CHAIN_FILE
  value: /opt/steadybit/agent/etc/{{ .directory }}/client/tls.crt
- name: {{ .env_prefix }}_CLIENT_CERT_KEY_FILE
  value: /opt/steadybit/agent/etc/{{ .directory }}/client/tls.key
{{ else if .tls.clientCertificate.path -}}
- name: {{ .env_prefix }}_CLIENT_CERT_CHAIN_FILE
  value: {{ .tls.clientCertificate.path | quote }}
{{ if .tls.clientCertificate.key.path -}}
- name: {{ .env_prefix }}_CLIENT_CERT_KEY_FILE
  value: {{ .tls.clientCertificate.key.path | quote }}
{{ end -}}
{{ end -}}
{{ if and .tls.clientCertificate.key.password.value (or .tls.clientCertificate.fromSecret .tls.clientCertificate.key.path) -}}
- name: {{ .env_prefix }}_CLIENT_CERT_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .secretName }}
      key: {{.directory}}ClientKeyPassword
{{ else if .tls.clientCertificate.key.password.valueFrom -}}
- name: {{ .env_prefix }}_CLIENT_CERT_PASSWORD
  valueFrom:
    {{- toYaml .tls.clientCertificate.key.password.valueFrom | nindent 4 }}
{{ end -}}
{{ if .tls.serverCertificate.fromSecret -}}
- name: {{ .env_prefix }}_SERVER_CERT
  value: /opt/steadybit/agent/etc/{{ .directory }}/server/tls.crt
{{ else if .tls.serverCertificate.path -}}
- name: {{ .env_prefix }}_SERVER_CERT
  value: {{ .tls.serverCertificate.path | quote }}
{{ end -}}
{{- end -}}


{{/*
generates volume mounts for mtls configuration
*/}}
{{- define "mtlsVolumeMounts" -}}
{{ if .tls.clientCertificate.fromSecret -}}
- name: {{ .directory }}-tls-client
  mountPath: /opt/steadybit/agent/etc/{{ .directory }}/client
  readOnly: true
{{ end -}}
{{ if .tls.serverCertificate.fromSecret -}}
- name: {{ .directory }}-tls-server
  mountPath: /opt/steadybit/agent/etc/{{ .directory }}/server
  readOnly: true
{{ end -}}
{{- end -}}

{{/*
generates volume mounts for mtls configuration
*/}}
{{- define "mtlsVolumes" -}}
{{ if .tls.clientCertificate.fromSecret -}}
- name: {{ .directory }}-tls-client
  secret:
    secretName: {{ .tls.clientCertificate.fromSecret | quote }}
{{ end -}}
{{ if .tls.serverCertificate.fromSecret -}}
- name: {{ .directory }}-tls-server
  secret:
    secretName: {{ .tls.serverCertificate.fromSecret | quote }}
{{ end -}}
{{- end -}}

{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "oauth2VolumeMounts" -}}
{{ include "mtlsVolumeMounts" (dict "directory" "oauth2" "tls" .Values.agent.auth.oauth2.tls) -}}
{{- end -}}

{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "oauth2Volumes" -}}
{{ include "mtlsVolumes" (dict "directory" "extensions" "tls" .Values.agent.auth.oauth2.tls "secretName" (include "steadybit-agent.fullname" . )) -}}
{{- end -}}

{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "extensionVolumeMounts" -}}
{{ include "mtlsVolumeMounts" (dict "directory" "extensions" "tls" .Values.agent.extensions.tls) -}}
{{- end -}}

{{/*
volumes for extension mTLS certificates
*/}}
{{- define "extensionVolumes" -}}
{{ include "mtlsVolumes" (dict "directory" "extensions" "tls" .Values.agent.extensions.tls "secretName" (include "steadybit-agent.fullname" . )) -}}
{{- end -}}