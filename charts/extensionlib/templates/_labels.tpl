{{- /*
extensionlib.labels will render a Kubernetes label definition supporting to be skipped form discovery.


*/}}
{{- define "extensionlib.labels" -}}
"steadybit.com/discovery-enabled": "false"
{{- end -}}
