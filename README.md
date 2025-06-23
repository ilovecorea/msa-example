# MSA Example with Kubernetes

이 프로젝트는 로컬 Kubernetes 환경에서 다양한 도구들을 사용하여 마이크로서비스 아키텍처(MSA)의 CI/CD 파이프라인과 모니터링을 구현하는 예제입니다.

## 🛠 포함된 도구들

### Core Infrastructure

- **Kubernetes**: 컨테이너 오케스트레이션 플랫폼
- **Harbor**: 컨테이너 레지스트리
- **Ingress-NGINX**: 인그레스 컨트롤러

### Service Mesh

- **Istio**: 서비스 메시
- **Kiali**: Istio 관리 및 모니터링

### 모니터링 & 로깅

- **Prometheus**: 메트릭 수집
- **AlertManager**: 알림 관리
- **Grafana**: 메트릭 대시보드
- **Fluent Bit**: 로그 수집
- **OpenSearch**: 로그 검색 엔진
- **OpenSearch Dashboard**: 로그 분석 대시보드
- **Jaeger**: 분산 추적

### CI/CD & Development

- **Gitea**: Git 서비스
- **Nexus**: 아티팩트 저장소
- **SonarQube**: 코드 품질 분석
- **Tekton**: 네이티브 Kubernetes CI/CD
- **Argo CD**: GitOps 기반 자동 배포
- **Trivy**: 컨테이너 이미지 취약점 스캔

### Security & Operations

- **Polaris**: Kubernetes 보안 스캔
- **Velero**: 백업 및 복구

### Infrastructure Management

- **Rancher**: Kubernetes 관리 플랫폼
- **Envoy**: 고성능 프록시 및 로드 밸런서

## 📁 프로젝트 구조

```
msa-example/
├── infra/                    # 인프라 설정
│   ├── local-setup/         # 로컬 환경 설정
│   ├── k8s/                 # Kubernetes 매니페스트
│   ├── helm/                # Helm 차트
│   └── docker/              # Docker 설정
├── services/                # 마이크로서비스들
│   ├── user-service/        # 사용자 서비스
│   ├── order-service/       # 주문 서비스
│   ├── product-service/     # 상품 서비스
│   └── gateway-service/     # API 게이트웨이
├── monitoring/              # 모니터링 설정
├── ci-cd/                   # CI/CD 파이프라인
└── docs/                    # 문서

```

## 🚀 빠른 시작

### 1. 사전 요구사항

- Docker Desktop
- kubectl
- Helm
- Kind 또는 Minikube

### 2. 로컬 환경 설정

```bash
# 프로젝트 클론 후
cd msa-example

# 로컬 Kubernetes 클러스터 생성
./scripts/setup-cluster.sh

# 모든 도구 설치
./scripts/install-all.sh
```

### 3. 서비스 배포

```bash
# 마이크로서비스 빌드 및 배포
./scripts/deploy-services.sh
```

## 📖 자세한 가이드

각 구성 요소에 대한 자세한 설정 및 사용 방법은 다음 문서들을 참조하세요:

- [로컬 환경 설정](./docs/local-setup.md)
- [Kubernetes 설정](./docs/kubernetes-setup.md)
- [모니터링 설정](./docs/monitoring-setup.md)
- [CI/CD 파이프라인](./docs/cicd-setup.md)
- [마이크로서비스 개발](./docs/microservices.md)

## 🏗 아키텍처

이 프로젝트는 다음과 같은 MSA 패턴을 구현합니다:

- API Gateway 패턴
- Service Discovery
- Circuit Breaker
- Distributed Tracing
- Centralized Logging
- Configuration Management

## 🔧 개발 환경

- Java 17+
- Spring Boot 3.x
- Maven/Gradle
- Docker
- Kubernetes

## 📝 라이선스

MIT License
