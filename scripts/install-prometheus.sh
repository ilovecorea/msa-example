#!/bin/bash

# Prometheus 및 AlertManager 설치 스크립트

set -e

echo "🔧 Prometheus 및 AlertManager 설치 시작..."

# Helm 레포지토리 추가
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 네임스페이스 생성
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Prometheus Stack 설치 (Prometheus + AlertManager + Grafana)
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=30005 \
  --set alertmanager.service.type=NodePort \
  --set alertmanager.service.nodePort=30006 \
  --set grafana.enabled=false \
  --set prometheusOperator.admissionWebhooks.enabled=false \
  --set prometheusOperator.tls.enabled=false \
  --wait

# 설치 확인
echo "⏳ Prometheus 서비스 준비 대기 중..."
kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=prometheus \
  --timeout=300s

echo "✅ Prometheus 및 AlertManager 설치 완료!"
echo "🌐 Prometheus 접속 URL: http://localhost:30005"
echo "🚨 AlertManager 접속 URL: http://localhost:30006" 