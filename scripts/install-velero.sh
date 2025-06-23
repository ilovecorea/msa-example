#!/bin/bash

# Velero 설치 스크립트

set -e

echo "🔧 Velero 설치 시작..."

# Helm 레포지토리 추가
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update

# 네임스페이스 생성
kubectl create namespace velero --dry-run=client -o yaml | kubectl apply -f -

# MinIO를 백업 스토리지로 설치
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: velero
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: minio/minio:latest
        args: ["server", "/data"]
        ports:
        - containerPort: 9000
        env:
        - name: MINIO_ROOT_USER
          value: "minio"
        - name: MINIO_ROOT_PASSWORD
          value: "minio123"
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: velero
spec:
  type: NodePort
  ports:
  - port: 9000
    targetPort: 9000
    nodePort: 30015
  selector:
    app: minio
EOF

# Velero 설치
helm upgrade --install velero vmware-tanzu/velero \
  --namespace velero \
  --set configuration.provider=aws \
  --set configuration.backupStorageLocation.bucket=velero \
  --set configuration.backupStorageLocation.config.region=minio \
  --set configuration.backupStorageLocation.config.s3ForcePathStyle=true \
  --set configuration.backupStorageLocation.config.s3Url=http://minio.velero.svc.cluster.local:9000 \
  --set credentials.useSecret=true \
  --set credentials.secretContents.cloud="[default]\naws_access_key_id = minio\naws_secret_access_key = minio123" \
  --wait

echo "✅ Velero 설치 완료!"
echo "🌐 MinIO 접속 URL: http://localhost:30015"
echo "👤 MinIO 계정: minio / minio123"
echo "💾 백업 명령 예시: velero backup create my-backup" 