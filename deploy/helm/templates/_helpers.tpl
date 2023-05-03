{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "app.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the health check path
*/}}

{{/*
Create secret key from environment variables
*/}}
{{- define "app.envkey" -}}
{{ . | replace "_" "-" | lower }}
{{- end -}}

{{/*
Create the healthCheckPath for readiness and liveness probes.

Based on the following template values:
    - healthCheckPath
    - ingress.path

The default is '/healthz'
*/}}

{{- define "app.healthCheckPath" -}}
{{- if .Values.healthCheckPath -}}
  {{ .Values.healthCheckPath }}
{{- else -}}
  {{- if .Values.ingress.enabled -}}
    {{ default "" .Values.ingress.path | trimSuffix "/" }}/health
  {{- else -}}
    {{ default "/health" }}
  {{- end -}}
{{- end -}}
{{- end -}}


{{- define "labels.recommend" }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/name: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ include "app.chart" . | quote }}
{{- end }}

{{- define "labels.selector" }}
app: {{ include "app.fullname" . | quote }}
{{- end -}}

{{- define "labels.standard" }}
app: {{ include "app.fullname" . }}
{{- include "labels.recommend" . }}
{{- end -}}