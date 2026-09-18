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
{{- $discovery := $top.Values.discovery | default dict -}}
{{- $globalDiscovery := (dig "discovery" dict ($top.Values.global | default dict)) | default dict -}}
{{- $group := $discovery.group | default (dig "group" "" $globalDiscovery) -}}
{{- if $group }}
- name: STEADYBIT_EXTENSION_DISCOVERY_GROUP
  value: {{ $group | quote }}
{{- end }}
{{- if $discovery.excludeQuery }}
- name: STEADYBIT_EXTENSION_DISCOVERY_EXCLUDE_QUERY
  value: {{ $discovery.excludeQuery | quote }}
{{- end }}
{{- if $discovery.includeQuery }}
- name: STEADYBIT_EXTENSION_DISCOVERY_INCLUDE_QUERY
  value: {{ $discovery.includeQuery | quote }}
{{- end }}
{{- /*
OpenTelemetry. Chart-level values win over global ones, so a collector can be
configured once for every extension and overridden where it differs. Nothing is
emitted unless an endpoint is set, which is what keeps tracing off by default.
*/}}
{{- $otel := $top.Values.otel | default dict -}}
{{- $globalOtel := (dig "otel" dict ($top.Values.global | default dict)) | default dict -}}
{{- $endpoint := $otel.endpoint | default (dig "endpoint" "" $globalOtel) -}}
{{- $tracesEndpoint := $otel.tracesEndpoint | default (dig "tracesEndpoint" "" $globalOtel) -}}
{{- $protocol := $otel.protocol | default (dig "protocol" "" $globalOtel) -}}
{{- $serviceName := $otel.serviceName | default (dig "serviceName" "" $globalOtel) -}}
{{- $disabled := $otel.disabled | default (dig "disabled" false $globalOtel) -}}
{{- if $endpoint }}
- name: OTEL_EXPORTER_OTLP_ENDPOINT
  value: {{ $endpoint | quote }}
{{- end }}
{{- if $tracesEndpoint }}
- name: OTEL_EXPORTER_OTLP_TRACES_ENDPOINT
  value: {{ $tracesEndpoint | quote }}
{{- end }}
{{- if $protocol }}
- name: OTEL_EXPORTER_OTLP_PROTOCOL
  value: {{ $protocol | quote }}
{{- end }}
{{- if or $endpoint $tracesEndpoint }}
{{- /*
Without a service name every extension reports as unknown_service:<binary>, so
default it to the release name rather than leaving traces unattributable.
*/}}
- name: OTEL_SERVICE_NAME
  value: {{ $serviceName | default (include "extensionlib.names.fullname" $top) | quote }}
{{- end }}
{{- if $disabled }}
- name: OTEL_SDK_DISABLED
  value: "true"
{{- end }}
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