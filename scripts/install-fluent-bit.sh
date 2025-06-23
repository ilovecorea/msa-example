#!/bin/bash

# Fluent Bit 설치 스크립트

set -e

echo "🔧 Fluent Bit 설치 시작..."

# Helm 레포지토리 추가
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

# Fluent Bit 설치
helm upgrade --install fluent-bit fluent/fluent-bit \
  --namespace opensearch \
  --set config.outputs="[OUTPUT]\n    Name opensearch\n    Match *\n    Host opensearch-cluster-master\n    Port 9200\n    Index kubernetes\n    Type _doc\n    Suppress_Type_Name On\n    tls Off" \
  --wait

# 설치 확인
echo "⏳ Fluent Bit 데몬셋 준비 대기 중..."
kubectl wait --namespace opensearch \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=fluent-bit \
  --timeout=300s

echo "✅ Fluent Bit 설치 완료!"
echo "📝 로그가 OpenSearch로 전송됩니다." 