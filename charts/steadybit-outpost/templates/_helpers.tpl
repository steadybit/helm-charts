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
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "steadybit-outpost.selectorLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-outpost.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
checks the outpost.leaderElection for valid values
*/}}
{{- define "validLeaderElection" -}}
{{- $valid := list "configmaps" "leases" -}}
{{- if has .Values.outpost.leaderElection $valid -}}
{{- .Values.outpost.leaderElection -}}
{{- else -}}
{{- fail (printf "unknown leader election: %s (must be one of %s)" .Values.outpost.leaderElection (join ", " $valid)) -}}
{{- end -}}
{{- end -}}

{{/*
checks if a volumne extra-cert is avaiable
*/}}
{{- define "steadybit-outpost.hasVolumeExtraCerts" -}}
  {{- $result := "false" -}}
  {{- range $vol := .Values.outpost.extraVolumes -}}
    {{- if eq $vol.name "extra-certs" -}}
     {{- $result = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{/*
extra volumes for extension mTLS certificates
*/}}
{{- define "volumesForExtensionMutualTlsCertificates" -}}
{{- range .Values.outpost.extensions.mutualTls.certificates.fromSecrets }}
- name: "extension-cert-{{ . }}"
  secret:
    secretName: {{ . | quote }}
    optional: false
{{- end -}}
{{- end -}}

{{/*
volume mounts for extension mTLS certificates
*/}}
{{- define "volumeMountsForExtensionMutualTlsCertificates" -}}
{{- range .Values.outpost.extensions.mutualTls.certificates.fromSecrets }}
- name: "extension-cert-{{ . }}"
  mountPath: "/opt/steadybit/outpost/etc/extension-mtls/{{ . }}"
  readOnly: true
{{- end -}}
{{- end -}}