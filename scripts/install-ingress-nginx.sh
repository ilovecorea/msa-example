#!/bin/bash

# Ingress NGINX 설치 스크립트

set -e

echo "🔧 Ingress NGINX 설치 시작..."

# Helm 레포지토리 추가
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# 네임스페이스 생성
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

# Ingress NGINX 설치
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443 \
  --set controller.hostNetwork=false \
  --set controller.kind=Deployment \
  --wait

# 설치 확인
echo "⏳ Ingress NGINX 컨트롤러 준비 대기 중..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "✅ Ingress NGINX 설치 완료!"
echo "🌐 접속 URL: http://localhost:30080" 