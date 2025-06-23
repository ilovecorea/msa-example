#!/bin/bash

# OpenSearch 및 OpenSearch Dashboard 설치 스크립트

set -e

echo "🔧 OpenSearch 및 Dashboard 설치 시작..."

# Helm 레포지토리 추가
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update

# 네임스페이스 생성
kubectl create namespace opensearch --dry-run=client -o yaml | kubectl apply -f -

# OpenSearch 설치
helm upgrade --install opensearch opensearch/opensearch \
  --namespace opensearch \
  --set replicas=1 \
  --set minimumMasterNodes=1 \
  --set persistence.enabled=false \
  --set security.enabled=false \
  --set service.type=NodePort \
  --set service.nodePort=30009 \
  --wait

# OpenSearch Dashboard 설치
helm upgrade --install opensearch-dashboards opensearch/opensearch-dashboards \
  --namespace opensearch \
  --set replicaCount=1 \
  --set service.type=NodePort \
  --set service.nodePort=30010 \
  --set opensearchHosts="http://opensearch-cluster-master:9200" \
  --set security.enabled=false \
  --wait

# 설치 확인
echo "⏳ OpenSearch 서비스 준비 대기 중..."
kubectl wait --namespace opensearch \
  --for=condition=ready pod \
  --selector=app=opensearch \
  --timeout=600s

echo "✅ OpenSearch 및 Dashboard 설치 완료!"
echo "🔍 OpenSearch 접속 URL: http://localhost:30009"
echo "📊 Dashboard 접속 URL: http://localhost:30010" 