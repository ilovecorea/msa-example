#!/bin/bash

# Tekton 설치 스크립트

set -e

echo "🔧 Tekton 설치 시작..."

# Tekton Pipelines 설치
echo "📦 Tekton Pipelines 설치 중..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Tekton Dashboard 설치
echo "📊 Tekton Dashboard 설치 중..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

# Tekton Triggers 설치 (선택사항)
echo "🚀 Tekton Triggers 설치 중..."
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Dashboard NodePort 서비스 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: tekton-dashboard-nodeport
  namespace: tekton-pipelines
spec:
  type: NodePort
  ports:
  - port: 9097
    targetPort: 9097
    nodePort: 30016
    protocol: TCP
  selector:
    app.kubernetes.io/name: tekton-dashboard
EOF

# 설치 확인
echo "⏳ Tekton 서비스 준비 대기 중..."
kubectl wait --namespace tekton-pipelines \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=tekton-dashboard \
  --timeout=300s

kubectl wait --namespace tekton-pipelines \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=tekton-pipelines-controller \
  --timeout=300s

echo "✅ Tekton 설치 완료!"
echo "🌐 Dashboard 접속 URL: http://localhost:30016"
echo "📋 Pipeline 생성 예시:"
echo "  kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/git-clone/0.9/git-clone.yaml" 