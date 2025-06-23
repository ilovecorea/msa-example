#!/bin/bash

# Harbor 설치 스크립트

set -e

echo "🔧 Harbor 설치 시작..."

# Helm 레포지토리 추가
helm repo add harbor https://helm.goharbor.io
helm repo update

# 네임스페이스 생성
kubectl create namespace harbor --dry-run=client -o yaml | kubectl apply -f -

# Harbor 설치
helm upgrade --install harbor harbor/harbor \
  --namespace harbor \
  --set expose.type=nodePort \
  --set expose.nodePort.ports.http.nodePort=30002 \
  --set expose.nodePort.ports.https.nodePort=30003 \
  --set persistence.enabled=false \
  --set externalURL=http://localhost:30002 \
  --set harborAdminPassword=Harbor12345 \
  --set database.internal.password=changeit \
  --set redis.internal.password=changeit \
  --wait

# 설치 확인
echo "⏳ Harbor 서비스 준비 대기 중..."
kubectl wait --namespace harbor \
  --for=condition=ready pod \
  --selector=app=harbor \
  --timeout=600s

echo "✅ Harbor 설치 완료!"
echo "🌐 접속 URL: http://localhost:30002"
echo "👤 관리자 계정: admin / Harbor12345" 