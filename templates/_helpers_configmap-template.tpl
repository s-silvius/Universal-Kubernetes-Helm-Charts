{{- define "configmap.template" -}}
{{- $configmapNamePostfix := .configmapNamePostfix | default "" -}}
{{- $configmapName := .configMapName | default "" -}}
{{- $configmapData := .data | default dict -}}
{{- $configmapDataFromfile := .dataFromfile | default dict -}}
{{- $annotations := .annotations | default dict -}}
{{- $files := .Files -}}

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "configmap.name" (dict "Values" .Values "configMapName" $configmapName "postfix" $configmapNamePostfix) }}
{{- include "labels" . | indent 2 }}
{{- if $annotations }}
  annotations:
{{ with $annotations -}}
{{ tpl ( toYaml .) $ | indent 4 }}
{{- end }}
{{- end }}
data:
  {{- range $key, $value := $configmapData }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
  # TODO: Helm Library charts has limitation that .Files.Get scope is chart specific
  # so it sees only files in the library chart folder and not in the main chart folder that uses library chart as an dependency.
  # So, currently only inlide data for configMaps are supported. If user wants to use .Files functions, need to create configMap manifest in the main chart folder.
  {{- range $key, $file := $configmapDataFromfile }}
  {{ $key }}: |
    {{ $files.Get $file | indent 4 }}
  {{- end }}
{{- end -}}