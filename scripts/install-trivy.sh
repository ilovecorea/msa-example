#!/bin/bash

# Trivy 취약점 스캔 도구 설치 스크립트

set -e

echo "🔧 Trivy 설치 시작..."

# Helm 레포지토리 추가
helm repo add aqua https://aquasecurity.github.io/helm-charts/
helm repo update

# 네임스페이스 생성
kubectl create namespace trivy-system --dry-run=client -o yaml | kubectl apply -f -

# Trivy Operator 설치
helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --set serviceMonitor.enabled=false \
  --set trivy.ignoreUnfixed=true \
  --wait

# Trivy Web UI 설치 (선택사항)
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trivy-web
  namespace: trivy-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: trivy-web
  template:
    metadata:
      labels:
        app: trivy-web
    spec:
      containers:
      - name: trivy-web
        image: aquasec/trivy:latest
        command: ["trivy"]
        args: ["server", "--listen", "0.0.0.0:8080"]
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: trivy-web-service
  namespace: trivy-system
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30023
  selector:
    app: trivy-web
EOF

# 설치 확인
echo "⏳ Trivy Operator 준비 대기 중..."
kubectl wait --namespace trivy-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=trivy-operator \
  --timeout=300s

echo "✅ Trivy 설치 완료!"
echo "🌐 Trivy Web UI: http://localhost:30023"
echo "🔍 취약점 스캔 명령 예시:"
echo "  kubectl get vulnerabilityreports -A"
echo "  kubectl get configauditreports -A" 