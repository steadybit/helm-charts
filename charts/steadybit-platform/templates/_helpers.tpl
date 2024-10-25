{{/* vim: set filetype=mustache: */}}

{{/*
ensures that no ingress is defined when port splitting is desired
*/}}
{{- define "validNoIngressWhenPortSplitting" -}}
{{- if and .Values.ingress.enabled .Values.platform.portSplit.enabled -}}
{{- fail (printf "Port splitting (platform.portSplit.enabled) and auto-generated ingress configurations (ingress.enabled) are mutually exclusive. Please disable one of these.") -}}
{{- end -}}
{{- end -}}

{{/*
ensures that an ingress origin is defined when port splitting
*/}}
{{- define "validIngressOriginWhenPortSplitting" -}}
{{- if and .Values.platform.portSplit.enabled (not .Values.platform.ingressOrigin) -}}
{{- fail (printf "Port splitting (platform.portSplit.enabled) requires a configured ingress origin (platform.ingressOrigin).") -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "steadybit-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "steadybit-platform.fullname" -}}
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
{{- define "steadybit-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use.
*/}}
{{- define "steadybit-platform.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "steadybit-platform.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Add Helm metadata to labels.
*/}}
{{- define "steadybit-platform.commonLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-platform.name" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "steadybit-platform.chart" . }}
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "steadybit-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Generates the dockerconfig for the credentials to pull from docker.steadybit.io.
*/}}
{{- define "imagePullSecretDockerRegistry" }}
{{- $registry := default "docker.steadybit.io" .Values.image.registry.url -}}
{{- $username := default "_" .Values.image.registry.user -}}
{{- $password := default .Values.platform.tenant.agentKey .Values.image.registry.password -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" $registry (printf "%s:%s" $username $password | b64enc) | b64enc }}
{{- end }}

{{/*
checks the platform.tenant.mode for valid values
*/}}
{{- define "validTenantMode" -}}
{{- $valid := list "SAAS" "ONPREM" -}}
{{- if has .Values.platform.tenant.mode $valid -}}
{{- .Values.platform.tenant.mode -}}
{{- else -}}
{{- fail (printf "unknown tenant mode: %s (must be one of %s)" .Values.platform.tenant.mode (join ", " $valid)) -}}
{{- end -}}
{{- end -}}

{{/*
checks if a volumne extra-cert is avaiable
*/}}
{{- define "steadybit-platform.hasVolumeExtraCerts" -}}
  {{- $result := "false" -}}
  {{- range $vol := .Values.platform.extraVolumes -}}
    {{- if eq $vol.name "extra-certs" -}}
     {{- $result = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}


{{- define "steadybit-platform.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
returns either the url or the data-url for an image
*/}}
{{- define "imageUrl" -}}
{{- if .url -}}
{{- .url -}}
{{- else if .data -}}
{{- printf "data:%s;base64,%s" .mediaType (.data | b64enc) -}}
{{- end -}}
{{- end -}}