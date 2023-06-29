{{- /*
extensionlib.annotation will render a Kubernetes daemonset definition supporting auto-discovery of the extension.

This takes an array of these values:
- the top context
- the port of the extension
- the supported types of the extension, e.g., (list "ACTION" "DISCOVERY")

*/}}
{{- define "extensionlib.annotation" -}}
{{- $top := index . 0 -}}
{{- $port := index . 1 -}}
{{- $types := index . 2 -}}
"steadybit.com/extension-auto-discovery": >
    {
    "extensions": [
      {
        "port": {{ $port }},
        "types": {{ toJson $types }},
        "tls": {
          {{- if $top.Values.tls.server.certificate.fromSecret }}
          "server": {
            "extraCertsFile": "{{ $top.Values.tls.server.certificate.fromSecret }}/tls.crt"
          {{ if $top.Values.tls.client.certificates.fromSecrets -}}
          },
          {{- else -}}
          }
          {{- end -}}
          {{- end }}
          {{ if $top.Values.tls.client.certificates.fromSecrets -}}
          "client": {
            "certChainFile": "{{ first $top.Values.tls.client.certificates.fromSecrets }}/tls.crt",
            "certKeyFile": "{{ first $top.Values.tls.client.certificates.fromSecrets }}/tls.key"
          }
          {{- end }}
        }
      }
    ]
    }
{{- end -}}
