{{/*
extensionlib.image renders the full container image reference.

It supports three modes:
  1. Legacy: image.name contains a registry (e.g. "ghcr.io/steadybit/ext")
     -> registry is NOT prepended (backwards compatible)
  2. Split with local override: image.registry is set
     -> "<image.registry>/<image.name>:<tag>"
  3. Split with global fallback: image.registry is null
     -> "<global.image.registry | ghcr.io>/<image.name>:<tag>"
*/}}
{{- define "extensionlib.image" -}}
{{- $name := .Values.image.name -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- $global := .Values.global | default dict -}}
{{- $globalImage := dig "image" dict $global -}}
{{- $firstSegment := (split "/" $name)._0 -}}
{{- if or (contains "." $firstSegment) (contains ":" $firstSegment) -}}
{{- printf "%s:%s" $name $tag -}}
{{- else -}}
{{- $registry := .Values.image.registry | default (dig "registry" "ghcr.io" $globalImage) -}}
{{- printf "%s/%s:%s" $registry $name $tag -}}
{{- end -}}
{{- end -}}

{{/*
extensionlib.imagePullPolicy resolves the image pull policy.

Precedence: image.pullPolicy > global.image.pullPolicy > IfNotPresent
*/}}
{{- define "extensionlib.imagePullPolicy" -}}
{{- $global := .Values.global | default dict -}}
{{- $globalImage := dig "image" dict $global -}}
{{- .Values.image.pullPolicy | default (dig "pullPolicy" "IfNotPresent" $globalImage) -}}
{{- end -}}

{{/*
extensionlib.imagePullSecrets renders imagePullSecrets for the pod spec.

Precedence: image.pullSecrets > global.image.pullSecrets > (none)
*/}}
{{- define "extensionlib.imagePullSecrets" -}}
{{- $global := .Values.global | default dict -}}
{{- $globalImage := dig "image" dict $global -}}
{{- $secrets := .Values.image.pullSecrets | default (dig "pullSecrets" (list) $globalImage) -}}
{{- if $secrets }}
imagePullSecrets:
{{- range $secrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
extensionlib.image.deprecationNotice prints a warning when image.name contains a registry prefix.
Include this in NOTES.txt to alert users about the legacy format.
*/}}
{{- define "extensionlib.image.deprecationNotice" -}}
{{- $name := .Values.image.name -}}
{{- $firstSegment := (split "/" $name)._0 -}}
{{- if or (contains "." $firstSegment) (contains ":" $firstSegment) }}
WARNING: image.name "{{ $name }}" contains a registry prefix.
  This format is deprecated. Please use the split format instead:
    image.registry: {{ $firstSegment }}
    image.name: {{ trimPrefix (printf "%s/" $firstSegment) $name }}
  Or rely on the global default:
    global.image.registry: {{ $firstSegment }}
{{- end -}}
{{- end -}}
