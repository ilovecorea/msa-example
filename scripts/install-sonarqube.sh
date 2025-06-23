#!/bin/bash

# SonarQube 설치 스크립트

set -e

echo "🔧 SonarQube 설치 시작..."

# Helm 레포지토리 추가
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update

# 네임스페이스 생성
kubectl create namespace sonarqube --dry-run=client -o yaml | kubectl apply -f -

# SonarQube 설치
helm upgrade --install sonarqube sonarqube/sonarqube \
  --namespace sonarqube \
  --set service.type=NodePort \
  --set service.nodePort=30013 \
  --set persistence.enabled=false \
  --set postgresql.persistence.enabled=false \
  --set sonarqubeFolder=/opt/sonarqube \
  --wait

# 설치 확인
echo "⏳ SonarQube 서비스 준비 대기 중..."
kubectl wait --namespace sonarqube \
  --for=condition=ready pod \
  --selector=app=sonarqube \
  --timeout=600s

echo "✅ SonarQube 설치 완료!"
echo "🌐 접속 URL: http://localhost:30013"
echo "👤 초기 관리자 계정: admin / admin" 