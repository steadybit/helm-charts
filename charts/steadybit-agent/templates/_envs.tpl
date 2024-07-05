{{/*
environment variables for oauth2 authentication
*/}}
{{- define "oauth2Env" -}}
{{- $secretName := include "steadybit-agent.fullname" . -}}
{{- if eq .Values.agent.auth.provider "oauth2" }}
{{- with .Values.agent.auth.oauth2 -}}
- name: STEADYBIT_AGENT_AUTH_PROVIDER
  value: "OAUTH2"
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_ID
  value: {{ .clientId | required "missing required .Values.agent.auth.oauth2.clientId" | quote }}
{{ if .clientSecret.value -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ $secretName }}
      key: oauth2ClientSecret
{{ else if .clientSecret.valueFrom -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_SECRET
  valueFrom:
    {{- toYaml .clientSecret.valueFrom | nindent 4 }}
{{ end -}}
{{ if .issuerUri -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_ISSUER_URI
  value: {{ .issuerUri | quote }}
{{ else if not .tokenUri -}}
{{- fail "missing either .Values.agent.auth.oauth2.issuerUri or .Values.agent.auth.oauth2.tokenUri" -}}
{{ end -}}
{{ if .audience -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_AUDIENCE
  value: {{ .audience | quote }}
{{ end -}}
{{ if .authorizationGrantType -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_AUTHORIZATION_GRANT_TYPE
  value: {{ .authorizationGrantType | quote }}
{{ end -}}
{{ if .clientAuthenticationMethod -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_CLIENT_AUTHENTICATION_METHOD
  value: {{ .clientAuthenticationMethod | quote }}
{{ end -}}
{{ if .tokenUri -}}
- name: STEADYBIT_AGENT_AUTH_OAUTH2_TOKEN_URI
  value: {{ .tokenUri | quote }}
{{ end -}}
{{ include "mtlsEnv" (dict "env_prefix" "STEADYBIT_AGENT_AUTH_OAUTH2" "values_prefix" ".Values.agent.auth.oauth2.tls" "directory" "oauth2" "tls" .tls "secretName" $secretName) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
environment variables for extension kit configuration
*/}}
{{- define "extensionEnv" -}}
{{ include "mtlsEnv" (dict "env_prefix" "STEADYBIT_AGENT_EXTENSIONS" "values_prefix" ".Values.agent.extensions.tls" "directory" "extensions" "tls" .Values.agent.extensions.tls "secretName" (include "steadybit-agent.fullname" . )) -}}
{{ if .Values.agent.extensions.tls.hostnameVerification -}}
- name: STEADYBIT_AGENT_EXTENSIONS_HOSTNAME_VERIFICATION
  value: {{ .Values.agent.extensions.tls.hostnameVerification | quote }}
{{ end -}}
{{- end -}}

{{/*
environment variables for extra certificates
*/}}
{{- define "extraCertificatesEnv" -}}
{{ if .Values.agent.extraCertificates.path -}}
- name: STEADYBIT_AGENT_EXTRA_CERTS_PATH
  value: {{ .Values.agent.extraCertificates.path | quote }}
{{ end -}}
{{- end -}}

{{/*
environment variables for redis state handling
*/}}
{{- define "redisStateEnv" -}}
- name: SPRING_DATA_REDIS_HOST
  value: {{ .Values.agent.persistence.redis.host | required "missing required .Values.agent.persistence.redis.host" | quote }}
- name: SPRING_DATA_REDIS_PORT
  value: {{ .Values.agent.persistence.redis.port | quote }}
{{ if .Values.agent.persistence.redis.username -}}
- name: SPRING_DATA_REDIS_USERNAME
  value: {{ .Values.agent.persistence.redis.username | quote }}
{{ end -}}
{{ if .Values.agent.persistence.redis.password.value -}}
- name: SPRING_DATA_REDIS_PASSWORD
  value: {{ .Values.agent.persistence.redis.password.value | quote }}
{{ end -}}
{{ if .Values.agent.persistence.redis.password.valueFrom -}}
- name: SPRING_DATA_REDIS_PASSWORD
  valueFrom:
    {{- toYaml .Values.agent.persistence.redis.password.valueFrom | nindent 4 }}
{{ end -}}
{{ if not (eq (.Values.agent.persistence.redis.db | int) 0) -}}
- name: SPRING_DATA_REDIS_DB
  value: {{ .Values.agent.persistence.redis.db | quote }}
{{ end -}}
{{ if .Values.agent.persistence.redis.sslEnabled -}}
- name: SPRING_DATA_REDIS_SSL_ENABLED
  value: {{ .Values.agent.persistence.redis.sslEnabled | quote }}
{{ end -}}
{{- end -}}


{{/*
environment variables for proxy configuration
*/}}
{{- define "proxyEnv" -}}
{{- end -}}