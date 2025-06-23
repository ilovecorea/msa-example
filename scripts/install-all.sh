#!/bin/bash

# 모든 구성 요소 설치 스크립트

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 MSA 예제 환경 설치를 시작합니다..."

# Helm 설치 확인
if ! command -v helm &> /dev/null; then
    echo "❌ Helm이 설치되어 있지 않습니다. Helm을 설치해주세요."
    echo "📋 설치 방법: https://helm.sh/docs/intro/install/"
    exit 1
fi

# 설치 스크립트들 실행 (아키텍처 순서대로)
# 1. 기본 인프라
basic_infra=(
    "install-ingress-nginx.sh"
    "install-rancher.sh"
)

# 2. CI/CD 영역 
cicd_tools=(
    "install-gitea.sh"
    "install-tekton.sh"
    "install-nexus.sh"
    "install-sonarqube.sh"
    "install-argocd.sh"
    "install-harbor.sh"
    "install-trivy.sh"
)

# 3. Telemetry 영역
telemetry_tools=(
    "install-opensearch.sh"
    "install-fluent-bit.sh"
    "install-prometheus.sh"
    "install-grafana.sh"
    "install-envoy.sh"
    "install-istio.sh"
    "install-kiali.sh"
    "install-jaeger.sh"
)

# 4. 추가 도구
additional_tools=(
    "install-polaris.sh"
    "install-velero.sh"
)

# 모든 스크립트 합치기
scripts=("${basic_infra[@]}" "${cicd_tools[@]}" "${telemetry_tools[@]}" "${additional_tools[@]}")

failed_scripts=()

for script in "${scripts[@]}"; do
    echo ""
    echo "🔧 $script 실행 중..."
    if "$SCRIPT_DIR/$script"; then
        echo "✅ $script 완료"
    else
        echo "❌ $script 실패"
        failed_scripts+=("$script")
    fi
done

echo ""
echo "📊 설치 결과 요약:"
if [ ${#failed_scripts[@]} -eq 0 ]; then
    echo "🎉 모든 구성 요소가 성공적으로 설치되었습니다!"
else
    echo "⚠️ 다음 스크립트들이 실패했습니다:"
    for script in "${failed_scripts[@]}"; do
        echo "  - $script"
    done
fi

echo ""
echo "🔗 다음 단계:"
echo "  1. kubectl get pods -A 로 모든 파드 상태 확인"
echo "  2. ./scripts/deploy-services.sh 로 마이크로서비스 배포"
echo "  3. 각 서비스 접속 URL 확인" 