{{- define "lifecycle.lifecycle-prestop" -}}
preStop:
  exec:
    command: ["sleep", "15"]
{{- end -}}
