#!/bin/bash

# Envoy 프록시 설치 스크립트

set -e

echo "🔧 Envoy 프록시 설치 시작..."

# 네임스페이스 생성
kubectl create namespace envoy --dry-run=client -o yaml | kubectl apply -f -

# Envoy ConfigMap 생성
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: envoy-config
  namespace: envoy
data:
  envoy.yaml: |
    admin:
      access_log_path: /tmp/admin_access.log
      address:
        socket_address: { address: 0.0.0.0, port_value: 9901 }
    
    static_resources:
      listeners:
      - name: listener_0
        address:
          socket_address: { address: 0.0.0.0, port_value: 10000 }
        filter_chains:
        - filters:
          - name: envoy.filters.network.http_connection_manager
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
              stat_prefix: ingress_http
              codec_type: AUTO
              route_config:
                name: local_route
                virtual_hosts:
                - name: local_service
                  domains: ["*"]
                  routes:
                  - match: { prefix: "/" }
                    route: { cluster: echo_service }
              http_filters:
              - name: envoy.filters.http.router
      
      clusters:
      - name: echo_service
        connect_timeout: 30s
        type: LOGICAL_DNS
        dns_lookup_family: V4_ONLY
        lb_policy: ROUND_ROBIN
        load_assignment:
          cluster_name: echo_service
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: httpbin.org
                    port_value: 80
EOF

# Envoy Deployment 생성
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: envoy
  namespace: envoy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: envoy
  template:
    metadata:
      labels:
        app: envoy
    spec:
      containers:
      - name: envoy
        image: envoyproxy/envoy:v1.28-latest
        ports:
        - containerPort: 10000
        - containerPort: 9901
        volumeMounts:
        - name: config
          mountPath: /etc/envoy
          readOnly: true
        command: ["/usr/local/bin/envoy"]
        args: ["-c", "/etc/envoy/envoy.yaml", "--service-cluster", "envoy"]
      volumes:
      - name: config
        configMap:
          name: envoy-config
---
apiVersion: v1
kind: Service
metadata:
  name: envoy-service
  namespace: envoy
spec:
  type: NodePort
  ports:
  - name: http
    port: 10000
    targetPort: 10000
    nodePort: 30017
  - name: admin
    port: 9901
    targetPort: 9901
    nodePort: 30018
  selector:
    app: envoy
EOF

# 설치 확인
echo "⏳ Envoy 서비스 준비 대기 중..."
kubectl wait --namespace envoy \
  --for=condition=ready pod \
  --selector=app=envoy \
  --timeout=300s

echo "✅ Envoy 설치 완료!"
echo "🌐 Envoy 프록시 URL: http://localhost:30017"
echo "⚙️ Envoy Admin 인터페이스: http://localhost:30018" 