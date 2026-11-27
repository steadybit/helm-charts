{{- /*
extensionlib.annotation will render a Kubernetes daemonset definition supporting auto-registration of the extension.

This takes an dict of these values:
- port: the port of the extension
- types: array of the supported types of the extension, e.g., (list "ACTION" "DISCOVERY")
- protocol: the protocol of the extension, e.g., "http" or "https"

*/}}
{{- define "extensionlib.annotation" -}}
{{- $top := index . 0 -}}
{{- $port := index . 1 -}}
{{- $types := index . 2 -}}
{{- $protocol := "http" -}}
{{- if (or $top.Values.tls.server.certificate.fromSecret $top.Values.tls.server.certificate.path) -}}
{{- $protocol = "https" -}}
{{- end -}}
"steadybit.com/extension-auto-discovery": >
    {{ toJson (dict "extensions" (list (dict "types" $types "protocol" $protocol "port" $port) ) ) }}
"steadybit.com/extension-auto-registration": >
    {{ toJson (dict "extensions" (list (dict "protocol" $protocol "port" $port) ) ) }}
{{- end -}}


{{- /*
extensionlib.podAnnotations will render .Values.podAnnotations together with the annotations opting the pod out of
the Dynatrace Operator injection (OneAgent and metadata enrichment). The opt-out is omitted when
.Values.dynatrace.inject is true. Keys set in .Values.podAnnotations take precedence. All values are rendered as
quoted strings. Renders nothing when there are no annotations.

This takes an array of these values:
- the top context

Usage: {{- with (include "extensionlib.podAnnotations" (list .)) }}{{- . | nindent 8 }}{{- end }}
*/}}
{{- define "extensionlib.podAnnotations" -}}
{{- $top := index . 0 -}}
{{- $annotations := dict -}}
{{- if ne (toString (dig "inject" false ($top.Values.dynatrace | default dict))) "true" -}}
{{- $_ := set $annotations "dynatrace.com/inject" "false" -}}
{{- $_ := set $annotations "oneagent.dynatrace.com/inject" "false" -}}
{{- $_ := set $annotations "metadata-enrichment.dynatrace.com/inject" "false" -}}
{{- end -}}
{{- range $key, $value := ($top.Values.podAnnotations | default dict) -}}
{{- $_ := set $annotations $key $value -}}
{{- end -}}
{{- $lines := list -}}
{{- range $key, $value := $annotations -}}
{{- $lines = append $lines (printf "%s: %s" ($key | quote) (ternary "" (toString $value) (kindIs "invalid" $value) | quote)) -}}
{{- end -}}
{{- join "\n" $lines -}}
{{- end -}}
