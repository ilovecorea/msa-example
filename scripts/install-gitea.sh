#!/bin/bash

# Gitea 설치 스크립트

set -e

echo "🔧 Gitea 설치 시작..."

# Helm 레포지토리 추가
helm repo add gitea-charts https://dl.gitea.io/charts/
helm repo update

# 네임스페이스 생성
kubectl create namespace gitea --dry-run=client -o yaml | kubectl apply -f -

# Gitea 설치
helm upgrade --install gitea gitea-charts/gitea \
  --namespace gitea \
  --set service.http.type=NodePort \
  --set service.http.nodePort=30011 \
  --set gitea.admin.username=admin \
  --set gitea.admin.password=admin123 \
  --set gitea.admin.email=admin@local.com \
  --set persistence.enabled=false \
  --set postgresql.persistence.enabled=false \
  --wait

# 설치 확인
echo "⏳ Gitea 서비스 준비 대기 중..."
kubectl wait --namespace gitea \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=gitea \
  --timeout=600s

echo "✅ Gitea 설치 완료!"
echo "🌐 접속 URL: http://localhost:30011"
echo "👤 관리자 계정: admin / admin123" 