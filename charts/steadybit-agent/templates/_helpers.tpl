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
Detect GKE Autopilot clusters via the auto.gke.io API group (WorkloadAllowlist /
AllowlistSynchronizer), which only Autopilot clusters serve. Renders "true" or "".
*/}}
{{- define "steadybit-agent.isGkeAutopilot" -}}
{{- if or (.Capabilities.APIVersions.Has "auto.gke.io/v1") (.Capabilities.APIVersions.Has "auto.gke.io/v1alpha1") -}}true{{- end -}}
{{- end -}}

{{/*
Whether the oom_score_adj feature is effectively enabled. Honors an explicit
agent.oomScoreAdj.enabled true/false; when null, it is enabled everywhere except on GKE
Autopilot, whose Warden admission webhook denies CAP_SYS_RESOURCE. Renders "true" or "".
Fails on non-boolean values (e.g. the string "false" from quoted YAML or --set-string),
which would otherwise be truthy and silently invert the user's intent.
*/}}
{{- define "steadybit-agent.oomScoreAdjEnabled" -}}
{{- $enabled := .Values.agent.oomScoreAdj.enabled -}}
{{- if not (or (kindIs "invalid" $enabled) (kindIs "bool" $enabled)) -}}
{{- fail (printf "agent.oomScoreAdj.enabled must be null, true or false - got the %s %q. Use an unquoted boolean (--set, not --set-string)." (kindOf $enabled) (toString $enabled)) -}}
{{- end -}}
{{- if kindIs "invalid" $enabled -}}
{{- if not (include "steadybit-agent.isGkeAutopilot" .) -}}true{{- end -}}
{{- else if $enabled -}}true{{- end -}}
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
{{/*
The default tag of the autoregistration sidecar lives in a Chart.yaml annotation instead of values.yaml, so that
templates can tell the chart's default apart from a user-supplied tag (see steadybit-agent.isOutdatedTag).
*/}}
{{- define "steadybit-agent.autoregistration.defaultTag" -}}
{{- index .Chart.Annotations "steadybit.com/autoregistration-version" | required "Chart.yaml annotation steadybit.com/autoregistration-version is missing" -}}
{{- end -}}

{{/*
steadybit-agent.images lists the images checked by steadybit-agent.isOutdatedTag, with the values key that sets each tag.
*/}}
{{- define "steadybit-agent.images" -}}
- name: {{ .Values.image.name | quote }}
  tag: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
  default: {{ .Chart.AppVersion | quote }}
  value: image.tag
{{- if not .Values.agent.extensions.autoregistration.useLegacyAutoregistration }}
{{- $default := include "steadybit-agent.autoregistration.defaultTag" . }}
- name: {{ .Values.agent.extensions.autoregistration.image.name | quote }}
  tag: {{ .Values.agent.extensions.autoregistration.image.tag | default $default | quote }}
  default: {{ $default | quote }}
  value: agent.extensions.autoregistration.image.tag
{{- end }}
{{- end -}}

{{/*
steadybit-agent.isOutdatedTag renders "true" if .tag is at least one minor version older than .default; patch
differences are ignored. Tags which are not plain semver (e.g. latest, a commit sha or a digest) are never reported.
*/}}
{{- define "steadybit-agent.isOutdatedTag" -}}
{{- $pattern := `^v?[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$` -}}
{{- $tag := toString .tag -}}
{{- $default := .default -}}
{{- if and (regexMatch $pattern $tag) (regexMatch $pattern $default) -}}
{{- $t := semver $tag -}}
{{- $d := semver $default -}}
{{- if or (lt $t.Major $d.Major) (and (eq $t.Major $d.Major) (lt $t.Minor $d.Minor)) -}}
true
{{- end -}}
{{- end -}}
{{- end -}}
