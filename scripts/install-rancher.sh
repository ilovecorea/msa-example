#!/bin/bash

# Rancher 설치 스크립트

set -e

echo "🔧 Rancher 설치 시작..."

# Helm 레포지토리 추가
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

# Cert-Manager 설치 (Rancher 필수 요구사항)
echo "🔐 Cert-Manager 설치 중..."
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --wait

# Rancher 네임스페이스 생성
kubectl create namespace cattle-system --dry-run=client -o yaml | kubectl apply -f -

# Rancher 설치
echo "🐄 Rancher 설치 중..."
helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.local \
  --set bootstrapPassword=admin123 \
  --set ingress.tls.source=rancher \
  --set service.type=NodePort \
  --set service.ports.http=30019 \
  --wait

# NodePort 서비스 생성 (추가 설정)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: rancher-nodeport
  namespace: cattle-system
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 30019
    protocol: TCP
  - name: https
    port: 443
    targetPort: 443
    nodePort: 30020
    protocol: TCP
  selector:
    app: rancher
EOF

# 설치 확인
echo "⏳ Rancher 서비스 준비 대기 중..."
kubectl wait --namespace cattle-system \
  --for=condition=ready pod \
  --selector=app=rancher \
  --timeout=600s

echo "✅ Rancher 설치 완료!"
echo "🌐 HTTP 접속 URL: http://localhost:30019"
echo "🔒 HTTPS 접속 URL: https://localhost:30020"
echo "👤 초기 관리자 비밀번호: admin123"
echo "⚠️  브라우저에서 'rancher.local'로 접속하려면 /etc/hosts에 '127.0.0.1 rancher.local' 추가 필요" 