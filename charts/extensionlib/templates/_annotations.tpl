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
