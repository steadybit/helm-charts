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
Create PodSecurityPolicy to be used.
*/}}
{{- define "steadybit-agent.podSecurityPolicyName" -}}
{{- if .Values.podSecurityPolicy.enable -}}
{{ default (include "steadybit-agent.fullname" .) .Values.podSecurityPolicy.name }}
{{- end -}}
{{- end -}}

{{/*
Add Helm metadata to labels.
*/}}
{{- define "steadybit-agent.commonLabels" -}}
com.steadybit.agent: "true"
app.kubernetes.io/name: {{ include "steadybit-agent.name" . }}
app.kubernetes.io/version: {{ .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "steadybit-agent.chart" . }}
{{- end -}}

{{/*
Add Helm metadata to selector labels specifically for deployments/daemonsets/statefulsets.
*/}}
{{- define "steadybit-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "steadybit-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Generates the dockerconfig for the credentials to pull from docker.steadybit.io.
*/}}
{{- define "imagePullSecretDockerRegistry" }}
{{- $registry := default "docker.steadybit.io" .Values.image.registry.url -}}
{{- $username := default "_" .Values.image.registry.user -}}
{{- $password := default .Values.agent.key .Values.image.registry.password -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" $registry (printf "%s:%s" $username $password | b64enc) | b64enc }}
{{- end }}

{{/*
checks the agent.containerRuntime for valid values
*/}}
{{- define "validContainerRuntime" -}}
{{- if .Values.agent.containerRuntime -}}
{{- $valid := list "docker" "crio" "containerd" -}}
{{- if has .Values.agent.containerRuntime $valid -}}
{{- .Values.agent.containerRuntime -}}
{{- else -}}
{{- fail (printf "unknown container driver: %s (must be one of %s)" .Values.agent.containerRuntime (join ", " $valid)) -}}
{{- end -}}
{{- else -}}
{{- "docker" -}}
{{- end -}}
{{- end -}}

{{/*
Determine the runc runtime root dir to mount
*/}}
{{- define "runc-root" -}}
{{- if eq "containerd" (include "validContainerRuntime" .) -}}
{{- "/run/containerd/runc/k8s.io" -}}
{{- else if eq "crio" (include "validContainerRuntime" .) -}}
{{- "/run/runc" -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}

{{/*
Determine the host path for the runc runtime root dir to mount
*/}}
{{- define "runc-root-host-path" -}}
{{- if .Values.agent.runcRoot -}}
{{- .Values.agent.runcRoot -}}
{{- else -}}
{{- include "runc-root" . -}}
{{- end -}}
{{- end -}}


{{/*
Determine the container runtime socket to mount
*/}}
{{- define "container-sock" -}}
{{- if eq "containerd" (include "validContainerRuntime" .) -}}
{{- "/run/containerd/containerd.sock" -}}
{{- else if eq "crio" (include "validContainerRuntime" .) -}}
{{- "/run/crio/crio.sock" -}}
{{- else -}}
{{- "/var/run/docker.sock" -}}
{{- end -}}
{{- end -}}

{{/*
Determine the host path for the container runtime socket to mount
*/}}
{{- define "container-sock-host-path" -}}
{{- if .Values.agent.containerRuntimeSocket -}}
{{- .Values.agent.containerRuntimeSocket -}}
{{- else -}}
{{- include "container-sock" . -}}
{{- end -}}
{{- end -}}