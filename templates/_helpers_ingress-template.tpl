{{- define "ingress.template" -}}
{{- $toplevel := . }}
{{- $ingressPathType := .pathType | default "Prefix" -}}
{{- $ingressClassName := .ingressClassName | default "" -}}
{{- $nginx_affinity := .nginx_affinity | default true -}}
{{- $hosts := .hosts -}}
{{- $enableMultiPath := .enableMultiPath | default false -}}
{{- $ingressApiIsStable := eq (include "ingress.isStable" .) "true" -}}
{{- $ingressSupportsIngressClassName := eq (include "ingress.supportsIngressClassName" .) "true" -}}
{{- $ingressSupportsPathType := eq (include "ingress.supportsPathType" .) "true" -}}
{{- $ingressNamePostfix := .ingressNamePostfix | default "" -}}
{{- $fullName := include "name" . }}
apiVersion: {{ template "ingress.apiVersion" . }}
kind: Ingress
metadata:
  name: {{ template "ingress.name" (dict "Values" .Values "postfix" $ingressNamePostfix) }}
{{- include "labels" . | indent 2 }}
  annotations:
{{- if and (not $ingressSupportsIngressClassName) .ingressClassName }}
    kubernetes.io/ingress.class: {{ .ingressClassName | quote }}
{{- end }}
{{ if $nginx_affinity }}
    nginx.ingress.kubernetes.io/affinity: "cookie"
    nginx.ingress.kubernetes.io/session-cookie-name: "route"
    nginx.ingress.kubernetes.io/session-cookie-path: "/"
    nginx.ingress.kubernetes.io/session-cookie-expires: "172800"
    nginx.ingress.kubernetes.io/session-cookie-max-age: "172800"
{{- end }}
{{ with .annotations -}}
{{ tpl ( toYaml .) $ | indent 4 }}
{{- end }}
spec:
  {{- if and $ingressSupportsIngressClassName .ingressClassName }}
  ingressClassName: {{ .ingressClassName }}
  {{- end }}
  rules:
  {{- range $hosts }}
    - host: {{ tpl .host $ | quote }}
      http:
        paths:
      {{- if $enableMultiPath -}}
        {{- range .paths }}
          - path: {{ .path }}
            {{- if $ingressSupportsPathType }}
            pathType: {{ .pathType | default $ingressPathType }}
            {{- end }}
            backend:
              {{- if $ingressApiIsStable }}
              service:
                name: {{ .serviceName }}
                port:
                  number: {{ .servicePort }}
              {{- else }}
              serviceName: {{ .serviceName }}
              servicePort: {{ .servicePort }}
              {{- end }}
        {{- end }}
      {{- else }}
        {{- range .paths }}
          - path: {{ . }}
            {{- if $ingressSupportsPathType }}
            pathType: {{ $ingressPathType }}
            {{- end }}
            backend:
              {{- if $ingressApiIsStable }}
              service:
                name: {{ $fullName }}
                port:
                  number: {{ $toplevel.Values.service.port }}
              {{- else }}
              serviceName: {{ $fullName }}
              servicePort: {{ $toplevel.Values.service.port }}
              {{- end }}
        {{- end }}
      {{- end }}
  {{- end }}

{{- with .Values.ingress.tls }}
  tls:
{{- range . }}
      - hosts:
        {{- range $elem, $elemVal := .hosts }}
        - {{ tpl $elemVal $ | quote }}
        {{- end }}
        {{- if .secretName }}
        secretName: {{ tpl .secretName $ | quote }}
        {{- end }}
{{- end }}
{{- end -}}
{{- end }}
