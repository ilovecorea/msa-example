#!/bin/bash

# Grafana 설치 스크립트

set -e

echo "🔧 Grafana 설치 시작..."

# Helm 레포지토리 추가
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Grafana 설치
helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  --set service.type=NodePort \
  --set service.nodePort=30007 \
  --set adminPassword=admin123 \
  --set datasources."datasources\.yaml".apiVersion=1 \
  --set datasources."datasources\.yaml".datasources[0].name=Prometheus \
  --set datasources."datasources\.yaml".datasources[0].type=prometheus \
  --set datasources."datasources\.yaml".datasources[0].url=http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090 \
  --set datasources."datasources\.yaml".datasources[0].access=proxy \
  --set datasources."datasources\.yaml".datasources[0].isDefault=true \
  --wait

# 설치 확인
echo "⏳ Grafana 서비스 준비 대기 중..."
kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=grafana \
  --timeout=300s

echo "✅ Grafana 설치 완료!"
echo "🌐 접속 URL: http://localhost:30007"
echo "👤 관리자 계정: admin / admin123" 