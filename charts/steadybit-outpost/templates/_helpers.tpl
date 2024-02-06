{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "steadybit-outpost.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "steadybit-outpost.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "steadybit-outpost.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "steadybit-outpost.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "steadybit-outpost.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role to use.

We cannot scope the cluster role natively via namespaces. So have have to do this by including the namespace name
within the cluster role's name. This in turn is necessary to support multiple steadybit outposts per Kubernetes
cluster.

Also see https://stackoverflow.com/questions/64871199/kubernetes-clusterrole-with-namespace-is-allowed
*/}}
{{- define "steadybit-outpost.clusterRoleName" -}}
{{- printf "%s-in-%s" (include "steadybit-outpost.fullname" .) .Release.Namespace -}}
{{- end -}}

{{/*
Add Helm metadata to labels.
*/}}
{{- define "steadybit-outpost.commonLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-outpost.name" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "steadybit-outpost.chart" . }}
steadybit.com/discovery-disabled: "true"
steadybit.com/outpost: "true"
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "steadybit-outpost.selectorLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-outpost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
environment variables for extra certificates
*/}}
{{- define "extraCertificatesEnv" -}}
{{ if .Values.outpost.extraCertificates.path -}}
- name: STEADYBIT_AGENT_EXTRA_CERTS_PATH
  value: {{ .Values.outpost.extraCertificates.path | quote }}
{{ end -}}
{{- end -}}

{{/*
environment variables for extra certificates
*/}}
{{- define "extraCertificatesVolumeMounts" -}}
{{ if .Values.outpost.extraCertificates.fromVolume -}}
- name: {{ .Values.outpost.extraCertificates.fromVolume }}
  mountPath: /opt/steadybit/outpost/etc/extra-certs
{{ end -}}
{{- end -}}

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
environment variables for oauth2 authentication
*/}}
{{- define "oauth2Env" -}}
{{- $secretName := include "steadybit-outpost.fullname" . -}}
{{- if eq .Values.outpost.auth.provider "oauth2" }}
{{- with .Values.outpost.auth.oauth2 -}}
- name: STEADYBIT_AGENT_AUTH_PROVIDER
  value: "OAUTH2"
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_ID
  value: {{ .clientId | required "missing required .Values.outpost.auth.oauth2.clientId" | quote }}
{{ if .clientSecret.value -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: oauth2ClientSecret
{{ else if .clientSecret.valueFrom -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_SECRET
  valueFrom:
    {{- toYaml .clientSecret.valueFrom | nindent 4 }}
{{ end -}}
{{ if .issuerUri -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_ISSUER_URI
  value: {{ .issuerUri | quote }}
{{ else if not .tokenUri -}}
{{- fail "missing either .Values.outpost.auth.oauth2.issuerUri or .Values.outpost.auth.oauth2.tokenUri" -}}
{{ end -}}
{{ if .audience -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_AUDIENCE
  value: {{ .audience | quote }}
{{ end -}}
{{ if .authorizationGrantType -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_AUTHORIZATION_GRANT_TYPE
  value: {{ .authorizationGrantType | quote }}
{{ end -}}
{{ if .clientAuthenticationMethod -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_AUTHENTICATION_METHOD
  value: {{ .clientAuthenticationMethod | quote }}
{{ end -}}
{{ if .tokenUri -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_TOKEN_URI
  value: {{ .tokenUri | quote }}
{{ end -}}
{{ include "mtlsEnv" (dict "env_prefix" "STEADYBIT_AGENT_AUTH_OAUTH2" "values_prefix" ".Values.outpost.auth.oauth2.tls" "directory" "oauth2" "tls" .tls "secretName" $secretName) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "oauth2VolumeMounts" -}}
{{ include "mtlsVolumeMounts" (dict "directory" "oauth2" "tls" .Values.outpost.auth.oauth2.tls) -}}
{{- end -}}

{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "oauth2Volumes" -}}
{{ include "mtlsVolumes" (dict "directory" "extensions" "tls" .Values.outpost.auth.oauth2.tls "secretName" (include "steadybit-outpost.fullname" . )) -}}
{{- end -}}

{{/*
environment variables for extension kit configuration
*/}}
{{- define "extensionEnv" -}}
{{ include "mtlsEnv" (dict "env_prefix" "STEADYBIT_AGENT_EXTENSIONS" "values_prefix" ".Values.outpost.extensions.tls" "directory" "extensions" "tls" .Values.outpost.extensions.tls "secretName" (include "steadybit-outpost.fullname" . )) -}}
{{ if .Values.outpost.extensions.tls.hostnameVerification -}}
- name: STEADYBIT_AGENT_EXTENSIONS_HOSTNAME_VERIFICATION
  value: {{ .Values.outpost.extensions.tls.hostnameVerification | quote }}
{{ end -}}
{{- end -}}


{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "extensionVolumeMounts" -}}
{{ include "mtlsVolumeMounts" (dict "directory" "extensions" "tls" .Values.outpost.extensions.tls) -}}
{{- end -}}

{{/*
volumes for extension mTLS certificates
*/}}
{{- define "extensionVolumes" -}}
{{ include "mtlsVolumes" (dict "directory" "extensions" "tls" .Values.outpost.extensions.tls "secretName" (include "steadybit-outpost.fullname" . )) -}}
{{- end -}}