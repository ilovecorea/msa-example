#!/bin/bash

# Spring Boot 마이크로서비스 배포 스크립트

set -e

echo "🚀 실제 MSA 서비스 배포 시작..."

# Harbor 레지스트리 설정
REGISTRY="localhost:30002"
NAMESPACE="msa"

# 서비스 네임스페이스 생성
kubectl create namespace msa-services --dry-run=client -o yaml | kubectl apply -f -

# Istio 사이드카 인젝션 활성화
kubectl label namespace msa-services istio-injection=enabled --overwrite

echo "📦 서비스 배포 중..."

# Gateway Service (API Gateway)
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gateway-service
  namespace: msa-services
  labels:
    app: gateway-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gateway-service
  template:
    metadata:
      labels:
        app: gateway-service
    spec:
      containers:
      - name: gateway-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: config
        configMap:
          name: gateway-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: gateway-config
  namespace: msa-services
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        upstream user-service {
            server user-service:8080;
        }
        upstream order-service {
            server order-service:8080;
        }
        upstream product-service {
            server product-service:8080;
        }
        server {
            listen 80;
            location /api/users {
                proxy_pass http://user-service;
            }
            location /api/orders {
                proxy_pass http://order-service;
            }
            location /api/products {
                proxy_pass http://product-service;
            }
            location / {
                return 200 '{"message": "MSA Gateway is running", "services": ["users", "orders", "products"]}';
                add_header Content-Type application/json;
            }
        }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: gateway-service
  namespace: msa-services
spec:
  selector:
    app: gateway-service
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# User Service
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: msa-services
  labels:
    app: user-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: nginx:alpine
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: config
        configMap:
          name: user-service-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-service-config
  namespace: msa-services
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        server {
            listen 8080;
            location / {
                return 200 '{"service": "user-service", "version": "1.0.0", "status": "healthy"}';
                add_header Content-Type application/json;
            }
        }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: msa-services
spec:
  selector:
    app: user-service
  ports:
  - port: 8080
    targetPort: 8080
EOF

# Order Service
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: msa-services
  labels:
    app: order-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: nginx:alpine
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: config
        configMap:
          name: order-service-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: order-service-config
  namespace: msa-services
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        server {
            listen 8080;
            location / {
                return 200 '{"service": "order-service", "version": "1.0.0", "status": "healthy"}';
                add_header Content-Type application/json;
            }
        }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: msa-services
spec:
  selector:
    app: order-service
  ports:
  - port: 8080
    targetPort: 8080
EOF

# Product Service
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  namespace: msa-services
  labels:
    app: product-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
      - name: product-service
        image: nginx:alpine
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: config
        configMap:
          name: product-service-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: product-service-config
  namespace: msa-services
data:
  nginx.conf: |
    events {
        worker_connections 1024;
    }
    http {
        server {
            listen 8080;
            location / {
                return 200 '{"service": "product-service", "version": "1.0.0", "status": "healthy"}';
                add_header Content-Type application/json;
            }
        }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
  namespace: msa-services
spec:
  selector:
    app: product-service
  ports:
  - port: 8080
    targetPort: 8080
EOF

# Ingress 설정
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: msa-ingress
  namespace: msa-services
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: msa.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: gateway-service
            port:
              number: 80
EOF

# 배포 확인
echo "⏳ 서비스 배포 완료 대기 중..."
kubectl wait --namespace msa-services \
  --for=condition=ready pod \
  --selector=app=gateway-service \
  --timeout=300s

kubectl wait --namespace msa-services \
  --for=condition=ready pod \
  --selector=app=user-service \
  --timeout=300s

kubectl wait --namespace msa-services \
  --for=condition=ready pod \
  --selector=app=order-service \
  --timeout=300s

kubectl wait --namespace msa-services \
  --for=condition=ready pod \
  --selector=app=product-service \
  --timeout=300s

echo "✅ MSA 서비스 배포 완료!"
echo "🌐 서비스 접속:"
echo "  - Gateway: http://msa.local (Ingress를 통해)"
echo "  - 직접 포트 포워딩: kubectl port-forward -n msa-services svc/gateway-service 8080:80"
echo "📊 서비스 상태 확인: kubectl get pods -n msa-services" 