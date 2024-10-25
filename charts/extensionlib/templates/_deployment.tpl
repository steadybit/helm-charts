{{- /*
extensionlib.deployment.env will render pod environment vars (without indentation) given globally applicable values.

This takes an array of these values:
- the top context
*/}}
{{- define "extensionlib.deployment.env" -}}
{{- $top := index . 0 -}}
- name: STEADYBIT_LOG_LEVEL
  value: {{ $top.Values.logging.level | quote }}
- name: STEADYBIT_LOG_FORMAT
  value: {{ $top.Values.logging.format | quote }}
{{ if $top.Values.tls.server.certificate.fromSecret -}}
- name: STEADYBIT_EXTENSION_TLS_SERVER_CERT
  value: "/etc/extension/certificates/{{ $top.Values.tls.server.certificate.fromSecret }}/tls.crt"
- name: STEADYBIT_EXTENSION_TLS_SERVER_KEY
  value: "/etc/extension/certificates/{{ $top.Values.tls.server.certificate.fromSecret }}/tls.key"
{{ else if $top.Values.tls.server.certificate.path -}}
- name: STEADYBIT_EXTENSION_TLS_SERVER_CERT
  value: {{ $top.Values.tls.server.certificate.path | quote }}
- name: STEADYBIT_EXTENSION_TLS_SERVER_KEY
  value: {{ $top.Values.tls.server.certificate.key.path | required "missing required .Values.tls.server.certificate.key.path" | quote }}
{{ end -}}
{{ if $top.Values.tls.client.certificates.fromSecrets -}}
- name: STEADYBIT_EXTENSION_TLS_CLIENT_CAS
  value: "/etc/extension/certificates/{{ join "/tls.crt,/etc/extension/certificates/" $top.Values.tls.client.certificates.fromSecrets }}/tls.crt"
{{ else if $top.Values.tls.client.certificates.paths -}}
- name: STEADYBIT_EXTENSION_TLS_CLIENT_CAS
  value: "{{ join "," $top.Values.tls.client.certificates.paths }}"
{{ end -}}
{{- end -}}

{{- /*
extensionlib.deployment.volumeMounts will render pod volume mounts(without indentation) given globally applicable values.

This takes an array of these values:
- the top context
*/}}
{{- define "extensionlib.deployment.volumeMounts" -}}
{{- $top := index . 0 -}}
{{ range uniq (without (append $top.Values.tls.client.certificates.fromSecrets $top.Values.tls.server.certificate.fromSecret) nil) }}
- name: "certificate-{{ . }}"
  mountPath: "/etc/extension/certificates/{{ . }}"
  readOnly: true
{{ end }}
{{- end -}}

{{- /*
extensionlib.deployment.volumes will render pod volumes (without indentation) given globally applicable values.

This takes an array of these values:
- the top context
*/}}
{{- define "extensionlib.deployment.volumes" -}}
{{- $top := index . 0 -}}
{{ range without (append $top.Values.tls.client.certificates.fromSecrets $top.Values.tls.server.certificate.fromSecret) nil | uniq }}
- name: "certificate-{{ . }}"
  secret:
    secretName: {{ . | quote }}
    optional: false
{{ end }}
{{- end -}}