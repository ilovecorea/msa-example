#!/bin/bash

# Jaeger 설치 스크립트

set -e

echo "🔧 Jaeger 설치 시작..."

# Helm 레포지토리 추가
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update

# 네임스페이스 생성
kubectl create namespace jaeger --dry-run=client -o yaml | kubectl apply -f -

# Jaeger 설치 (All-in-One 모드)
helm upgrade --install jaeger jaegertracing/jaeger \
  --namespace jaeger \
  --set provisionDataStore.cassandra=false \
  --set storage.type=memory \
  --set allInOne.enabled=true \
  --set query.service.type=NodePort \
  --set query.service.nodePort=30008 \
  --set collector.service.type=ClusterIP \
  --set agent.enabled=false \
  --wait

# 설치 확인
echo "⏳ Jaeger 서비스 준비 대기 중..."
kubectl wait --namespace jaeger \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=jaeger \
  --timeout=300s

echo "✅ Jaeger 설치 완료!"
echo "🌐 접속 URL: http://localhost:30008" 