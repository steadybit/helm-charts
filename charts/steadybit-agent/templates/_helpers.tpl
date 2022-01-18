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


{{- define "defaultedRuntime" -}}
{{- if or .Values.agent.openshift (.Capabilities.APIVersions.Has "apps.openshift.io/v1") -}}
    {{- default "crio" .Values.agent.containerRuntime -}}
{{- else -}}
    {{- default "docker" .Values.agent.containerRuntime -}}
{{- end -}}
{{- end -}}


{{/*
checks the agent.containerRuntime for valid values
*/}}
{{- define "validContainerRuntime" -}}
{{- $valid := list "docker" "crio" "containerd" -}}
{{- $runtime := (include "defaultedRuntime" .) -}}
{{- if has $runtime $valid -}}
{{- $runtime -}}
{{- else -}}
{{- fail (printf "unknown container driver: %s (must be one of %s)" $runtime (join ", " $valid)) -}}
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

{{/*
extra mounts for using containerd/crio
*/}}
{{- define "containerRuntimeVolumes" -}}
{{- if eq "containerd" (include "validContainerRuntime" .) -}}
- name: container-run
  hostPath:
    path: /run/containerd
- name: container-namespaces
  hostPath:
    path: /var/run
{{- else if eq "crio" (include "validContainerRuntime" .) -}}
- name: container-run
  hostPath:
    path: /run/containers
- name: container-lib
  hostPath:
    path: /var/lib/containers
- name: container-namespaces
  hostPath:
    path: /var/run
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
extra mounts for using containerd/crio
*/}}
{{- define "containerRuntimeVolumeMounts" -}}
{{- if eq "containerd" (include "validContainerRuntime" .) -}}
- name: container-run
  mountPath: /run/containerd
- name: container-namespaces
  mountPath: /var/run
  mountPropagation: Bidirectional
{{- else if eq "crio" (include "validContainerRuntime" .) -}}
- name: container-run
  mountPath: /run/containers
- name: container-lib
  mountPath: /var/lib/containers
- name: container-namespaces
  mountPath: /var/run
  mountPropagation: Bidirectional
{{- end -}}
{{- end -}}

{{/*
checks the agent.leaderElection for valid values
*/}}
{{- define "validLeaderElection" -}}
{{- $valid := list "configmaps" "leases" -}}
{{- if has .Values.agent.leaderElection $valid -}}
{{- .Values.agent.leaderElection -}}
{{- else -}}
{{- fail (printf "unknown leader election: %s (must be one of %s)" .Values.agent.leaderElection (join ", " $valid)) -}}
{{- end -}}
{{- end -}}

{{/*
checks the agent.mode for valid values
*/}}
{{- define "validAgentMode" -}}
{{- $valid := list "default" "aws" -}}
{{- if has .Values.agent.mode $valid -}}
{{- .Values.agent.mode -}}
{{- else -}}
{{- fail (printf "unknown agent mode: %s (must be one of %s)" .Values.agent.leaderElection (join ", " $valid)) -}}
{{- end -}}
{{- end -}}


{{/*
checks if a volumne extra-cert is avaiable
*/}}
{{- define "steadybit-agent.hasVolumeExtraCerts" -}}
  {{- $result := "false" -}}
  {{- range $vol := .Values.agent.extraVolumes -}}
    {{- if eq $vol.name "extra-certs" -}}
     {{- $result = "true" -}}
    {{- end -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}