#!/bin/bash

# Kiali 설치 스크립트

set -e

echo "🔧 Kiali 설치 시작..."

# Helm 레포지토리 추가
helm repo add kiali https://kiali.org/helm-charts
helm repo update

# Kiali 설치
helm upgrade --install kiali-server kiali/kiali-server \
  --namespace istio-system \
  --set auth.strategy=anonymous \
  --set deployment.service_type=NodePort \
  --set deployment.service_annotations.'service\.beta\.kubernetes\.io/port_30004'=30004 \
  --wait

# NodePort 서비스 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: kiali-nodeport
  namespace: istio-system
spec:
  type: NodePort
  ports:
  - port: 20001
    targetPort: 20001
    nodePort: 30004
    protocol: TCP
  selector:
    app.kubernetes.io/name: kiali
EOF

# 설치 확인
echo "⏳ Kiali 서비스 준비 대기 중..."
kubectl wait --namespace istio-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=kiali \
  --timeout=300s

echo "✅ Kiali 설치 완료!"
echo "🌐 접속 URL: http://localhost:30004" 