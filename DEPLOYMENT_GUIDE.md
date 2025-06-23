# 🚀 MSA 예제 전체 배포 가이드

이 가이드를 따라하면 완전한 MSA 환경을 로컬에서 구축할 수 있습니다.

## 📋 사전 요구사항

다음 도구들이 설치되어 있어야 합니다:

- **Docker Desktop** (실행 중이어야 함)
- **kubectl**
- **Helm**
- **Kind** (Kubernetes in Docker)
- **Maven** (Java 프로젝트 빌드용)
- **Node.js** (프론트엔드 빌드용)

### 설치 명령어 (macOS 기준)

```bash
# Docker Desktop은 공식 사이트에서 설치
# https://www.docker.com/products/docker-desktop

# Homebrew로 나머지 도구들 설치
brew install kubectl helm kind maven node
```

## 🎯 1단계: Kubernetes 클러스터 생성

```bash
# 프로젝트 디렉토리로 이동
cd msa-example

# 스크립트 실행 권한 부여
chmod +x scripts/*.sh

# Kind 클러스터 생성
./scripts/setup-cluster.sh
```

**예상 결과:**

- `msa-local` 이름의 Kind 클러스터 생성
- kubectl 컨텍스트 자동 설정
- 클러스터 정보 출력

## 🔧 2단계: 인프라 도구 설치

```bash
# 모든 인프라 도구 설치 (15-30분 소요)
./scripts/install-all.sh
```

**설치되는 도구들:**

- ✅ Ingress NGINX
- ✅ Rancher (Kubernetes 관리)
- ✅ Gitea (Git 서비스)
- ✅ Tekton (CI/CD)
- ✅ Nexus (아티팩트 저장소)
- ✅ SonarQube (코드 품질)
- ✅ Argo CD (배포 자동화)
- ✅ Harbor (컨테이너 레지스트리)
- ✅ Trivy (취약점 스캔)
- ✅ OpenSearch & Dashboard (로깅)
- ✅ Fluent Bit (로그 수집)
- ✅ Prometheus (메트릭)
- ✅ Grafana (모니터링 대시보드)
- ✅ Envoy (프록시)
- ✅ Istio (서비스 메시)
- ✅ Kiali (서비스 메시 시각화)
- ✅ Jaeger (분산 추적)
- ✅ Polaris (보안 스캔)
- ✅ Velero (백업)

## 🏗 3단계: MSA 서비스 빌드

```bash
# Spring Boot 서비스들과 React 프론트엔드 빌드
./scripts/build-services.sh
```

**빌드되는 서비스들:**

- 🔧 user-service (사용자 관리 API)
- 🔧 order-service (주문 관리 API)
- 🔧 product-service (상품 관리 API)
- 🔧 gateway-service (API Gateway)
- 🌐 frontend-service (React 프론트엔드)

## 📦 4단계: Harbor에 이미지 푸시

```bash
# Harbor 레지스트리에 로그인
docker login localhost:30002 -u admin -p Harbor12345

# 빌드된 이미지들을 Harbor에 푸시
docker push localhost:30002/msa/user-service:latest
docker push localhost:30002/msa/order-service:latest
docker push localhost:30002/msa/product-service:latest
docker push localhost:30002/msa/gateway-service:latest
docker push localhost:30002/msa/frontend-service:latest
```

## 🚀 5단계: MSA 서비스 배포

```bash
# Kubernetes에 MSA 서비스들 배포
./scripts/deploy-services.sh
```

## 🌐 6단계: 서비스 접속 URL 확인

```bash
# 모든 서비스 URL 출력
./scripts/show-urls.sh
```

## 📊 7단계: 동작 확인

### A. 웹 UI 접속

1. **Rancher (클러스터 관리)**: http://localhost:30019

   - 계정: admin / admin123

2. **Harbor (이미지 저장소)**: http://localhost:30002

   - 계정: admin / Harbor12345

3. **Grafana (모니터링)**: http://localhost:30007

   - 계정: admin / admin123

4. **Argo CD (배포 관리)**: http://localhost:30021
   - 계정: admin / (초기 비밀번호는 설치 후 확인)

### B. MSA 서비스 테스트

```bash
# /etc/hosts 파일에 도메인 추가 (macOS/Linux)
echo "127.0.0.1 msa.local gateway.local" | sudo tee -a /etc/hosts

# API 테스트
curl -X GET http://gateway.local/api/users
curl -X POST http://gateway.local/api/users \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","name":"Test User"}'

# 프론트엔드 접속
open http://msa.local
```

### C. 모니터링 확인

1. **Prometheus**: http://localhost:30005

   - 메트릭 쿼리: `up{job="kubernetes-pods"}`

2. **Jaeger**: http://localhost:30008

   - 분산 추적 확인

3. **Kiali**: http://localhost:30004
   - 서비스 메시 시각화

## 🔍 8단계: 트러블슈팅

### 파드 상태 확인

```bash
# 모든 네임스페이스의 파드 상태 확인
kubectl get pods -A

# 특정 파드 로그 확인
kubectl logs -n msa-services deployment/user-service

# 파드 재시작
kubectl rollout restart deployment/user-service -n msa-services
```

### 서비스 상태 확인

```bash
# 서비스 엔드포인트 확인
kubectl get svc -A

# 인그레스 확인
kubectl get ingress -A
```

### 리소스 정리

```bash
# 전체 클러스터 삭제
kind delete cluster --name msa-local

# Docker 이미지 정리
docker system prune -a
```

## 🎯 다음 단계

1. **CI/CD 파이프라인 구성**

   - Tekton Pipeline 설정
   - Argo CD Application 생성

2. **실제 개발 시나리오**

   - 코드 변경 → Git Push → 자동 빌드 → 자동 배포

3. **운영 모니터링**

   - Grafana 대시보드 커스터마이징
   - 알림 규칙 설정

4. **보안 강화**
   - Trivy 취약점 스캔 자동화
   - Polaris 보안 정책 적용

---

## 🆘 도움이 필요한 경우

1. **로그 확인**: `kubectl logs -f deployment/서비스명 -n 네임스페이스`
2. **파드 상태**: `kubectl describe pod 파드명 -n 네임스페이스`
3. **서비스 디버깅**: `kubectl port-forward svc/서비스명 로컬포트:서비스포트 -n 네임스페이스`

🎉 **축하합니다! 완전한 MSA 환경이 구축되었습니다!**
