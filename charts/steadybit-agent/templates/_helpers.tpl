{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "steadybit-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "steadybit-agent.fullname" -}}
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
{{- define "steadybit-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "steadybit-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "steadybit-agent.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the cluster role to use.

We cannot scope the cluster role natively via namespaces. So have have to do this by including the namespace name
within the cluster role's name. This in turn is necessary to support multiple steadybit agents per Kubernetes
cluster.

Also see https://stackoverflow.com/questions/64871199/kubernetes-clusterrole-with-namespace-is-allowed
*/}}
{{- define "steadybit-agent.clusterRoleName" -}}
{{- printf "%s-in-%s" (include "steadybit-agent.fullname" .) .Release.Namespace -}}
{{- end -}}

{{/*
Add Helm metadata to labels.
*/}}
{{- define "steadybit-agent.commonLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-agent.name" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "steadybit-agent.chart" . }}
steadybit.com/discovery-disabled: "true"
steadybit.com/agent: "true"
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "steadybit-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
volume mounts for extra certificates
*/}}
{{- define "extraCertificatesVolumeMounts" -}}
{{ if .Values.agent.extraCertificates.fromVolume -}}
- name: {{ .Values.agent.extraCertificates.fromVolume }}
  mountPath: /opt/steadybit/agent/etc/extra-certs
{{ end -}}
{{- end -}}

{{/*
Map match labels to extension registration JSON format.
*/}}
{{- define "matchLabelsJson" -}}
{{- $result := list -}}
{{- range $key, $value := . -}}
  {{- $item := dict "key" $key "value" (toString $value) -}}
  {{- $result = append $result $item -}}
{{- end -}}
{{- $result | toJson -}}
{{- end -}}