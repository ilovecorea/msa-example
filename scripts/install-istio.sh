#!/bin/bash

# Istio 설치 스크립트

set -e

echo "🔧 Istio 설치 시작..."

# Istio 다운로드 및 설치
ISTIO_VERSION="1.20.1"

if [ ! -d "istio-${ISTIO_VERSION}" ]; then
    echo "📥 Istio ${ISTIO_VERSION} 다운로드 중..."
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
fi

# PATH에 istioctl 추가
export PATH=$PWD/istio-${ISTIO_VERSION}/bin:$PATH

# Istio 설치
echo "⚙️ Istio 컨트롤 플레인 설치 중..."
istioctl install --set values.defaultRevision=default -y

# 자동 사이드카 인젝션을 위한 네임스페이스 레이블링
kubectl label namespace default istio-injection=enabled --overwrite

# Istio 게이트웨이 설치
echo "🌐 Istio Gateway 설정 중..."
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: default-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
EOF

# 설치 확인
echo "⏳ Istio 구성 요소 준비 대기 중..."
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s

echo "✅ Istio 설치 완료!"
echo "🔍 Istio 상태 확인: istioctl version" 