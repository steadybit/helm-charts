{{- define "podTemplate" }}
  template:
    metadata:
      labels:
        {{- include "steadybit-agent.commonLabels" . | nindent 8 }}
        {{- range $key, $value := .Values.agent.extraLabels }}
        {{ $key }}: {{ $value }}
        {{- end }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      annotations:
        prometheus.io/scrape: "{{ .Values.agent.prometheus.scrape }}"
        prometheus.io/path: "/prometheus"
        prometheus.io/port: "{{ .Values.agent.port }}"
        oneagent.dynatrace.com/injection: "false"
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      serviceAccountName: {{ template "steadybit-agent.serviceAccountName" . }}
      automountServiceAccountToken: true
      {{- if .Values.priorityClassName.use }}
      priorityClassName: {{ .Values.priorityClassName.name }}
      {{- end }}
      securityContext:
        {{- with .Values.podSecurityContext }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      containers:
        {{- if .Values.agent.extensions.autoregistration.beta.enabled }}
        - name: "steadybit-agent-kubernetes-autoregistration"
          image: "{{ .Values.agent.extensions.autoregistration.beta.image.name }}:{{ .Values.agent.extensions.autoregistration.beta.image.tag }}"
          imagePullPolicy: {{ .Values.agent.extensions.autoregistration.beta.image.pullPolicy }}
          resources:
            requests:
              memory: {{ .Values.agent.extensions.autoregistration.beta.resources.requests.memory }}
              cpu: {{ .Values.agent.extensions.autoregistration.beta.resources.requests.cpu }}
            {{- if or .Values.agent.extensions.autoregistration.beta.resources.limits.memory .Values.agent.extensions.autoregistration.beta.resources.limits.cpu }}
            limits:
              {{- if .Values.agent.extensions.autoregistration.beta.resources.limits.memory }}
              memory: {{ .Values.agent.extensions.autoregistration.beta.resources.limits.memory }}
              {{- end }}
              {{- if .Values.agent.extensions.autoregistration.beta.resources.limits.cpu }}
              cpu: {{ .Values.agent.extensions.autoregistration.beta.resources.limits.cpu }}
              {{- end }}
            {{- end }}
          securityContext:
            {{- with .Values.containerSecurityContext }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
            runAsUser: 10000
            runAsNonRoot: true
          env:
            - name: STEADYBIT_LOG_LEVEL
              value: {{ .Values.logging.level | quote }}
            - name: STEADYBIT_LOG_FORMAT
              value: {{ .Values.logging.format | quote }}
            {{ if .Values.agent.key -}}
            - name: STEADYBIT_EXTENSION_AGENT_KEY
              valueFrom:
                secretKeyRef:
                  name: {{ template "steadybit-agent.fullname" . }}
                  key: key
            {{ end -}}
            - name: STEADYBIT_EXTENSION_AGENT_PORT
              value: {{ .Values.agent.port | quote }}
            {{ if .Values.agent.extensions.autoregistration.namespace -}}
            - name: STEADYBIT_EXTENSION_NAMESPACE_FILTER
              value: {{ .Values.agent.extensions.autoregistration.namespace | quote }}
            {{ end -}}
            {{- if .Values.agent.extensions.autoregistration.matchLabels }}
            - name: STEADYBIT_EXTENSION_MATCH_LABELS
              value: {{ include "matchLabelsJson" .Values.agent.extensions.autoregistration.matchLabels | quote }}
            {{- end }}
            {{- if .Values.agent.extensions.autoregistration.matchLabelsExclude }}
            - name: STEADYBIT_EXTENSION_MATCH_LABELS_EXCLUDE
              value: {{ include "matchLabelsJson" .Values.agent.extensions.autoregistration.matchLabelsExclude | quote }}
            {{- end }}
        {{- end }}
        - name: steadybit-agent
          image: "{{ .Values.image.name }}:{{ default .Chart.AppVersion .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          resources:
            requests:
              memory: {{ .Values.resources.requests.memory }}
              cpu: {{ .Values.resources.requests.cpu }}
            {{- if or .Values.resources.limits.memory .Values.resources.limits.cpu }}
            limits:
              {{- if .Values.resources.limits.memory }}
              memory: {{ .Values.resources.limits.memory }}
              {{- end }}
              {{- if .Values.resources.limits.cpu }}
              cpu: {{ .Values.resources.limits.cpu }}
              {{- end }}
            {{- end }}
          {{- if .Values.agent.livenessProbe.enabled }}
          livenessProbe:
            httpGet:
              port: {{ .Values.agent.port }}
              path: /health
            initialDelaySeconds: {{ .Values.agent.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.agent.livenessProbe.periodSeconds }}
            timeoutSeconds: {{ .Values.agent.livenessProbe.timeoutSeconds }}
            successThreshold: {{ .Values.agent.livenessProbe.successThreshold }}
            failureThreshold: {{ .Values.agent.livenessProbe.failureThreshold }}
          {{- end }}
          env:
            - name: STEADYBIT_LOG_LEVEL
              value: {{ .Values.logging.level | quote }}
            - name: STEADYBIT_LOG_FORMAT
              value: {{ .Values.logging.format | quote }}
            - name: STEADYBIT_AGENT_REGISTER_URL
              value: {{ .Values.agent.registerUrl | quote }}
            {{ if .Values.agent.key -}}
            - name: STEADYBIT_AGENT_KEY
              valueFrom:
                secretKeyRef:
                  name: {{ template "steadybit-agent.fullname" . }}
                  key: key
            {{ end -}}
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: STEADYBIT_KUBERNETES_CLUSTER_NAME
              value: {{ .Values.global.clusterName | quote }}
            - name: STEADYBIT_AGENT_POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: STEADYBIT_AGENT_POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            {{- if and (eq .Values.agent.persistence.provider "filesystem") (.Values.agent.identifier)}}
            - name: STEADYBIT_AGENT_IDENTIFIER
              value: {{.Values.agent.identifier | quote}}
            {{ else if eq .Values.agent.persistence.provider "filesystem"}}
            - name: STEADYBIT_AGENT_IDENTIFIER
              value: "{{.Values.global.clusterName}}/{{.Release.Namespace}}/%HOSTNAME%"
            {{ else if eq .Values.agent.persistence.provider "redis"}}
            - name: STEADYBIT_AGENT_IDENTIFIER
              value: {{.Values.agent.identifier | quote | required "missing required .Values.agent.identifier for redis persistence" }}
            {{ end -}}
            {{ if ne (int .Values.agent.port) 42899 }}
            - name: SERVER_PORT
              value: {{ .Values.agent.port | quote }}
            {{ end -}}
            {{- if .Values.agent.proxy.host }}
            - name: STEADYBIT_AGENT_PROXY_HOST
              value: {{ .Values.agent.proxy.host | quote }}
            - name: STEADYBIT_AGENT_PROXY_PORT
              value: {{ .Values.agent.proxy.port | quote }}
            - name: STEADYBIT_AGENT_PROXY_PROTOCOL
              value: {{ .Values.agent.proxy.protocol | quote }}
            {{- end }}
            {{- if .Values.agent.proxy.user }}
            - name: STEADYBIT_AGENT_PROXY_USER
              value: {{ .Values.agent.proxy.user | quote }}
            - name: STEADYBIT_AGENT_PROXY_PASSWORD
              value: {{ .Values.agent.proxy.password | quote }}
            {{- end }}
            - name: STEADYBIT_AGENT_WORKING_DIR
              value: /tmp/steadybit-agent
            {{ if .Values.agent.aws.accountId -}}
            - name: STEADYBIT_AGENT_AWS_ACCOUNT_ID
              value: "{{.Values.agent.aws.accountId}}"
            {{ end -}}
            {{- if eq .Values.agent.persistence.provider "redis"}}
            {{- include "redisStateEnv" . | nindent 12 }}
            {{- end }}
            {{- include "oauth2Env" . | nindent 12 }}
            {{- include "extensionEnv" . | nindent 12 }}
            {{- include "extraCertificatesEnv" . | nindent 12 }}
            {{ $matchLabelCounter := 0 | int }}
            {{- range $key, $value := merge .Values.agent.extensions.autoregistration.matchLabels .Values.agent.extensions.autodiscovery.matchLabels }}
            - name: STEADYBIT_AGENT_EXTENSIONS_AUTOREGISTRATION_MATCHLABELS_{{$matchLabelCounter}}_KEY
              value: {{ $key }}
            - name: STEADYBIT_AGENT_EXTENSIONS_AUTOREGISTRATION_MATCHLABELS_{{$matchLabelCounter}}_VALUE
              value: {{ $value }}
            {{ $matchLabelCounter = add1 $matchLabelCounter }}
            {{- end }}
            {{ $matchLabelExcludeCounter := 0 | int }}
            {{- range $key, $value := merge .Values.agent.extensions.autoregistration.matchLabelsExclude .Values.agent.extensions.autodiscovery.matchLabelsExclude }}
            - name: STEADYBIT_AGENT_EXTENSIONS_AUTOREGISTRATION_MATCHLABELSEXCLUDE_{{$matchLabelExcludeCounter}}_KEY
              value: {{ $key }}
            - name: STEADYBIT_AGENT_EXTENSIONS_AUTOREGISTRATION_MATCHLABELSEXCLUDE_{{$matchLabelExcludeCounter}}_VALUE
              value: {{ $value }}
            {{ $matchLabelExcludeCounter = add1 $matchLabelExcludeCounter }}
            {{- end }}
            {{ if or .Values.agent.extensions.autodiscovery.namespace .Values.agent.extensions.autoregistration.namespace -}}
            - name: STEADYBIT_AGENT_EXTENSIONS_AUTOREGISTRATION_NAMESPACE
              value: "{{ coalesce .Values.agent.extensions.autoregistration.namespace .Values.agent.extensions.autodiscovery.namespace}}"
            {{ end -}}
            {{ if .Values.agent.extensions.autoregistration.beta.enabled -}}
            - name: STEADYBIT_AGENT_DISABLE_KUBERNETES_ACCESS
              value: "true"
            {{ end -}}
            {{- with .Values.agent.env }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          securityContext:
            {{- with .Values.containerSecurityContext }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
          volumeMounts:
            {{- if eq .Values.agent.persistence.provider "filesystem"}}
            - name: steadybit-agent-state
              mountPath: /var/lib/steadybit-agent
            {{- end }}
            - name: tmp-dir
              mountPath: /tmp
            {{- include "oauth2VolumeMounts" . | nindent 12 }}
            {{- include "extensionVolumeMounts" . | nindent 12 }}
            {{- include "extraCertificatesVolumeMounts" . | nindent 12 }}
            {{- with .Values.agent.extraVolumeMounts  }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
      {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if .Values.image.pullSecrets }}
      imagePullSecrets:
        {{- range .Values.image.pullSecrets }}
        - name: {{ . }}
        {{- end }}
      {{- end }}
      volumes:
        - name: tmp-dir
          emptyDir:
            medium: Memory
        {{-  include "oauth2Volumes" . | nindent 8 }}
        {{-  include "extensionVolumes" . | nindent 8 }}
      {{- with .Values.agent.extraVolumes  }}
      {{ toYaml . | nindent 8 }}
      {{- end }}
{{- end }}