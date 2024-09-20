{{- define "affinity.podAntiAffinity" -}}
- weight: 100
  podAffinityTerm:
    topologyKey: "kubernetes.io/hostname"
    labelSelector:
      matchExpressions:
      - key: app.kubernetes.io/name
        operator: In
        values:
        - {{ template "name" . }}
- weight: 100
  podAffinityTerm:
    topologyKey: "topology.kubernetes.io/zone"
    labelSelector:
      matchExpressions:
      - key: app.kubernetes.io/name
        operator: In
        values:
        - {{ template "name" . }}
{{- end -}}