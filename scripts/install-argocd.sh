#!/bin/bash

# Argo CD 설치 스크립트

set -e

echo "🔧 Argo CD 설치 시작..."

# 네임스페이스 생성
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Argo CD 설치
echo "📦 Argo CD 설치 중..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Argo CD Server UI를 NodePort로 노출
kubectl patch svc argocd-server -n argocd -p '{"spec":{"type":"NodePort","ports":[{"port":80,"targetPort":8080,"nodePort":30021},{"port":443,"targetPort":8080,"nodePort":30022}]}}'

# 설치 확인
echo "⏳ Argo CD 서비스 준비 대기 중..."
kubectl wait --namespace argocd \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=argocd-server \
  --timeout=600s

# 초기 admin 비밀번호 가져오기
echo "🔑 Argo CD 초기 admin 비밀번호 설정 중..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ Argo CD 설치 완료!"
echo "🌐 HTTP 접속 URL: http://localhost:30021"
echo "🔒 HTTPS 접속 URL: https://localhost:30022"
echo "👤 관리자 계정: admin"
echo "🔑 초기 비밀번호: ${ARGOCD_PASSWORD}"
echo ""
echo "📝 비밀번호 변경 방법:"
echo "  argocd account update-password --account admin --current-password ${ARGOCD_PASSWORD} --new-password 새비밀번호" 