#!/bin/bash

# Polaris 설치 스크립트

set -e

echo "🔧 Polaris 설치 시작..."

# Helm 레포지토리 추가
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo update

# 네임스페이스 생성
kubectl create namespace polaris --dry-run=client -o yaml | kubectl apply -f -

# Polaris 설치
helm upgrade --install polaris fairwinds-stable/polaris \
  --namespace polaris \
  --set dashboard.enable=true \
  --set dashboard.service.type=NodePort \
  --set dashboard.service.nodePort=30014 \
  --set webhook.enable=false \
  --wait

# 설치 확인
echo "⏳ Polaris 서비스 준비 대기 중..."
kubectl wait --namespace polaris \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=polaris \
  --timeout=300s

echo "✅ Polaris 설치 완료!"
echo "🌐 접속 URL: http://localhost:30014"
echo "🔒 Kubernetes 보안 스캔 결과를 확인하세요." 