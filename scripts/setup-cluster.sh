#!/bin/bash

# 로컬 Kubernetes 클러스터 설정 스크립트
# Kind를 사용하여 클러스터 생성

set -e

CLUSTER_NAME="msa-local"
KIND_CONFIG="infra/local-setup/kind-config.yaml"

echo "🚀 로컬 Kubernetes 클러스터 설정을 시작합니다..."

# Kind 설치 확인
if ! command -v kind &> /dev/null; then
    echo "❌ Kind가 설치되어 있지 않습니다. Kind를 설치해주세요."
    echo "📋 설치 방법: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Docker 실행 확인
if ! docker info &> /dev/null; then
    echo "❌ Docker가 실행되고 있지 않습니다. Docker Desktop을 시작해주세요."
    exit 1
fi

# 기존 클러스터 삭제 (선택사항)
if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "🗑 기존 클러스터 '$CLUSTER_NAME'를 삭제합니다..."
    kind delete cluster --name "$CLUSTER_NAME"
fi

# 클러스터 생성
echo "🔧 새로운 클러스터 '$CLUSTER_NAME'를 생성합니다..."
kind create cluster --name "$CLUSTER_NAME" --config "$KIND_CONFIG"

# kubectl 컨텍스트 설정
echo "⚙️ kubectl 컨텍스트를 설정합니다..."
kubectl config use-context "kind-$CLUSTER_NAME"

# 클러스터 정보 확인
echo "✅ 클러스터 설정 완료!"
echo "📊 클러스터 정보:"
kubectl cluster-info
kubectl get nodes

echo ""
echo "🎉 클러스터 '$CLUSTER_NAME'가 성공적으로 생성되었습니다!"
echo "🔗 다음 단계: ./scripts/install-all.sh를 실행하여 모든 도구를 설치하세요." 