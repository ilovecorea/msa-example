#!/bin/bash

# Nexus 설치 스크립트

set -e

echo "🔧 Nexus 설치 시작..."

# 네임스페이스 생성
kubectl create namespace nexus --dry-run=client -o yaml | kubectl apply -f -

# Nexus 배포
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nexus
  namespace: nexus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nexus
  template:
    metadata:
      labels:
        app: nexus
    spec:
      containers:
      - name: nexus
        image: sonatype/nexus3:latest
        ports:
        - containerPort: 8081
        env:
        - name: INSTALL4J_ADD_VM_PARAMS
          value: "-Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=512m"
---
apiVersion: v1
kind: Service
metadata:
  name: nexus-service
  namespace: nexus
spec:
  type: NodePort
  ports:
  - port: 8081
    targetPort: 8081
    nodePort: 30012
  selector:
    app: nexus
EOF

# 설치 확인
echo "⏳ Nexus 서비스 준비 대기 중..."
kubectl wait --namespace nexus \
  --for=condition=ready pod \
  --selector=app=nexus \
  --timeout=600s

echo "✅ Nexus 설치 완료!"
echo "🌐 접속 URL: http://localhost:30012"
echo "👤 초기 관리자 비밀번호는 컨테이너 내부 /nexus-data/admin.password 파일에서 확인하세요." 